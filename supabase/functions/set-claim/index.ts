import * as jose from "npm:jose@^5.9.6";

const FIREBASE_PROJECT_ID = "electronic-health-record-f67ee";
const FIREBASE_JWKS_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
const FIREBASE_ISSUER = `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;

// Remote JWKS instance (caches Google public signing keys automatically)
const jwks = jose.createRemoteJWKSet(new URL(FIREBASE_JWKS_URL));

// CORS headers to permit requests from Flutter Web and mobile clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ServiceAccountCredentials {
  client_email: string;
  private_key: string;
  project_id?: string;
}

/**
 * Exchanges the Firebase service account private key for a temporary
 * Google Cloud OAuth 2.0 access token with identitytoolkit and datastore scopes.
 */
async function getGoogleAccessToken(
  sa: ServiceAccountCredentials
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const privateKey = await jose.importPKCS8(sa.private_key, "RS256");

  const jwt = await new jose.SignJWT({
    scope:
      "https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/datastore",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!res.ok) {
    const errorBody = await res.text();
    throw new Error(`Google OAuth2 token exchange failed: ${errorBody}`);
  }

  const tokenData = await res.json();
  return tokenData.access_token;
}

/**
 * Queries Firestore REST API for the user's document at /users/{uid}.
 *
 * Security Enforcement (FAIL CLOSED):
 * - Accepts ONLY exact roles: "Doctor" or "Patient".
 * - Throws an error if document is missing, 'role' field is missing, or 'role' is invalid.
 * - Never defaults to "Patient" or any other value.
 */
async function getUserRoleFromFirestore(
  uid: string,
  accessToken: string
): Promise<"Doctor" | "Patient"> {
  const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${uid}`;

  const res = await fetch(firestoreUrl, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
  });

  if (res.status === 404) {
    throw new Error(
      `User profile document '/users/${uid}' was not found in Firestore.`
    );
  }

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(
      `Firestore lookup failed with HTTP ${res.status}: ${errText}`
    );
  }

  const docData = await res.json();
  const rawRole = docData.fields?.role?.stringValue;

  if (!rawRole) {
    throw new Error(
      `Firestore document '/users/${uid}' does not contain a valid string 'role' field.`
    );
  }

  if (rawRole !== "Doctor" && rawRole !== "Patient") {
    throw new Error(
      `Invalid role '${rawRole}' in Firestore for user '${uid}'. Expected 'Doctor' or 'Patient'.`
    );
  }

  return rawRole;
}

/**
 * Main Deno HTTP request handler for the set-claim Edge Function.
 */
Deno.serve(async (req: Request) => {
  // 1. Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // 2. Only allow POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed. Use POST." }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }

  try {
    // 3. Extract Firebase ID token from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({
          error:
            "Missing or malformed Authorization header. Expected Bearer <token>.",
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const idToken = authHeader.replace("Bearer ", "").trim();

    // 4. Cryptographically verify the Firebase ID token with Google's public JWKS
    let payload: jose.JWTPayload;
    try {
      const verificationResult = await jose.jwtVerify(idToken, jwks, {
        issuer: FIREBASE_ISSUER,
        audience: FIREBASE_PROJECT_ID,
      });
      payload = verificationResult.payload;
    } catch (verifyErr) {
      console.error("Firebase ID token verification failed:", verifyErr);
      return new Response(
        JSON.stringify({
          error: "Invalid or expired Firebase ID token.",
          details:
            verifyErr instanceof Error ? verifyErr.message : String(verifyErr),
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 5. Obtain UID STRICTLY from the verified token's `sub` claim.
    // NEVER trust or read any UID or role from the request body.
    const verifiedUid = payload.sub;
    if (!verifiedUid || typeof verifiedUid !== "string") {
      return new Response(
        JSON.stringify({
          error: "Verified token is missing a valid subject (sub) claim.",
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 6. Retrieve Firebase service-account secret from Edge Function environment
    const serviceAccountSecret = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountSecret) {
      console.error(
        "Missing FIREBASE_SERVICE_ACCOUNT environment secret in Supabase."
      );
      return new Response(
        JSON.stringify({
          error:
            "Server configuration error: Firebase service account secret is not configured.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    let saCredentials: ServiceAccountCredentials;
    try {
      saCredentials = JSON.parse(serviceAccountSecret);
      if (!saCredentials.client_email || !saCredentials.private_key) {
        throw new Error(
          "Service account JSON must contain client_email and private_key."
        );
      }
    } catch (parseErr) {
      console.error("Failed to parse FIREBASE_SERVICE_ACCOUNT JSON:", parseErr);
      return new Response(
        JSON.stringify({
          error:
            "Server configuration error: Invalid Firebase service account JSON format.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 7. Obtain Google OAuth2 access token
    const googleAccessToken = await getGoogleAccessToken(saCredentials);

    // 8. Query Firestore /users/{verifiedUid} to derive the application role.
    // Enforces FAIL-CLOSED semantics: rejects if doc or role is missing or invalid.
    let appRole: "Doctor" | "Patient";
    try {
      appRole = await getUserRoleFromFirestore(verifiedUid, googleAccessToken);
    } catch (firestoreErr) {
      console.error("Firestore role verification failed:", firestoreErr);
      return new Response(
        JSON.stringify({
          error: "Failed to verify application role from Firestore.",
          details:
            firestoreErr instanceof Error
              ? firestoreErr.message
              : String(firestoreErr),
        }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 9. Lookup current user claims from Firebase Identity Toolkit to preserve existing claims
    const lookupRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/accounts:lookup`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${googleAccessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ localId: [verifiedUid] }),
      }
    );

    if (!lookupRes.ok) {
      const errText = await lookupRes.text();
      console.error("Firebase accounts:lookup error:", errText);
      return new Response(
        JSON.stringify({
          error: "Failed to look up user account in Firebase.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const lookupData = await lookupRes.json();
    const userRecord = lookupData.users?.[0];
    if (!userRecord) {
      return new Response(
        JSON.stringify({
          error: `User with UID ${verifiedUid} not found in Firebase.`,
        }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse existing custom attributes (claims)
    let existingClaims: Record<string, unknown> = {};
    if (userRecord.customAttributes) {
      try {
        existingClaims = JSON.parse(userRecord.customAttributes);
      } catch {
        existingClaims = {};
      }
    }

    // Check if both role and app_role are already correctly set
    if (
      existingClaims.role === "authenticated" &&
      existingClaims.app_role === appRole
    ) {
      return new Response(
        JSON.stringify({
          success: true,
          uid: verifiedUid,
          app_role: appRole,
          alreadySet: true,
          message:
            "Custom claims 'role: authenticated' and 'app_role' are already present.",
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 10. Merge existing claims with role: "authenticated" and verified app_role
    const mergedClaims = {
      ...existingClaims,
      role: "authenticated",
      app_role: appRole,
    };

    // 11. Update custom claims in Firebase Identity Toolkit
    const updateRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/accounts:update`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${googleAccessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          localId: verifiedUid,
          customAttributes: JSON.stringify(mergedClaims),
        }),
      }
    );

    if (!updateRes.ok) {
      const errText = await updateRes.text();
      console.error("Firebase accounts:update error:", errText);
      return new Response(
        JSON.stringify({
          error: "Failed to set custom claims on Firebase user account.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(
      `Successfully assigned role: "authenticated", app_role: "${appRole}" to UID: ${verifiedUid}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        uid: verifiedUid,
        app_role: appRole,
        alreadySet: false,
        message: `Custom claims ('role: authenticated', 'app_role: ${appRole}') successfully assigned.`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Unexpected error in set-claim function:", err);
    return new Response(
      JSON.stringify({
        error: "Internal server error occurred while processing claim.",
        details: err instanceof Error ? err.message : String(err),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
