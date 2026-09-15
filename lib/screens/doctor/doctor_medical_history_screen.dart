import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/medical_history_model.dart';
import '../../services/medical_history_service.dart';
import '../../widgets/attachment_view_widget.dart';
import 'patient_list_screen.dart';

class DoctorMedicalHistoryScreen extends StatefulWidget {
  const DoctorMedicalHistoryScreen({super.key});

  @override
  State<DoctorMedicalHistoryScreen> createState() =>
      _DoctorMedicalHistoryScreenState();
}

class _DoctorMedicalHistoryScreenState
    extends State<DoctorMedicalHistoryScreen> {
  final MedicalHistoryService _service = MedicalHistoryService();
  String _searchQuery = "";
  final String _selectedCategory = "All";

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'allergies':
        return Colors.red;
      case 'previous surgery':
        return Colors.deepOrange;
      case 'hospitalization':
        return Colors.amber.shade900;
      case 'previous diagnosis':
        return Colors.blue;
      case 'existing conditions':
        return Colors.purple;
      case 'previous medications':
        return Colors.teal;
      case 'family history':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  void _confirmDelete(BuildContext context, MedicalHistoryModel history) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Medical History"),
        content: const Text(
          "Are you sure you want to delete this medical history entry and its attachments? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              try {
                await _service.deleteHistory(history);

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Medical history entry deleted"),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete medical history: $e"),
                  ),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Medical History"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add History"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PatientListScreen(
                mode: PatientListMode.addMedicalHistory,
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search condition, title, notes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MedicalHistoryModel>>(
              stream: _service.getAssignedHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Unable to load medical history.\n"
                        "You can only view medical history of patients "
                        "currently assigned to you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                final allEntries = snapshot.data ?? [];

                final entries = allEntries.where((h) {
                  final matchesCategory = _selectedCategory == "All" ||
                      h.category.toLowerCase() ==
                          _selectedCategory.toLowerCase();

                  final matchesSearch = _searchQuery.isEmpty ||
                      h.title.toLowerCase().contains(_searchQuery) ||
                      h.category.toLowerCase().contains(_searchQuery) ||
                      h.description.toLowerCase().contains(_searchQuery) ||
                      h.notes.toLowerCase().contains(_searchQuery) ||
                      h.doctorName.toLowerCase().contains(_searchQuery);

                  return matchesCategory && matchesSearch;
                }).toList();

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_edu_outlined,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Medical History Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "Try adjusting your search criteria."
                              : "Medical history will appear here for your assigned patients.",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 80,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final history = entries[index];
                    final catColor =
                        _getCategoryColor(history.category);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: catColor.withAlpha(30),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: catColor.withAlpha(90),
                                    ),
                                  ),
                                  child: Text(
                                    history.category,
                                    style: TextStyle(
                                      color: catColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(
                                    context,
                                    history,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              history.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(history.historyDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.medical_services_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    history.doctorName,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (history.description.isNotEmpty) ...[
                              const Divider(height: 18),
                              Text(
                                history.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                            if (history.notes.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Notes: ${history.notes}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                            if (history.attachments.isNotEmpty) ...[
                              AttachmentViewWidget(
                                attachments: history.attachments,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}