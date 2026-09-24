import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

Future<void> showLanguageSelectorDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => const LanguageSelectorDialog(),
  );
}

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = context.l10n;
    final currentCode = localeProvider.locale.languageCode;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.language, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            l10n.selectLanguage,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: currentCode == 'en' ? Colors.blue : Colors.grey.shade200,
              child: Text(
                'EN',
                style: TextStyle(
                  color: currentCode == 'en' ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            title: const Text(
              'English',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text('Default'),
            trailing: currentCode == 'en'
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            onTap: () {
              localeProvider.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: currentCode == 'mr' ? Colors.blue : Colors.grey.shade200,
              child: Text(
                'म',
                style: TextStyle(
                  color: currentCode == 'mr' ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: const Text(
              'मराठी',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text('Marathi'),
            trailing: currentCode == 'mr'
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            onTap: () {
              localeProvider.setLocale(const Locale('mr'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
