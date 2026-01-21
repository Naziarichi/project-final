import 'package:flutter/material.dart';
import 'package:richi1196/medicine_service.dart';

class MedicinesTab extends StatefulWidget {
  const MedicinesTab({super.key});

  @override
  State<MedicinesTab> createState() => _MedicinesTabState();
}

class _MedicinesTabState extends State<MedicinesTab> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = MedicineService.fetchMedicines();
  }

  Future<void> refresh() async {
    setState(() {
      future = MedicineService.fetchMedicines();
    });
  }

  Future<void> _openEditDialog(Map<String, dynamic> m) async {
    final id = m['id'] as int;

    final nameC = TextEditingController(text: (m['name'] ?? '').toString());
    final dosageC = TextEditingController(text: (m['dosage'] ?? '').toString());
    final notesC = TextEditingController(text: (m['notes'] ?? '').toString());
    final timesC = TextEditingController(
      text: (m['times_per_day'] ?? 1).toString(),
    );

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Medicine"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameC,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Enter name"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: dosageC,
                        decoration: const InputDecoration(
                          labelText: "Dosage",
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: timesC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Times per day",
                          prefixIcon: Icon(Icons.timelapse),
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? "").trim());
                          if (n == null || n <= 0)
                            return "Enter a valid number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: notesC,
                        decoration: const InputDecoration(
                          labelText: "Notes",
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() => saving = true);

                          try {
                            await MedicineService.updateMedicine(
                              id: id,
                              name: nameC.text.trim(),
                              dosage: dosageC.text.trim(),
                              notes: notesC.text.trim(),
                              timesPerDay: int.parse(timesC.text.trim()),
                            );

                            if (context.mounted) Navigator.pop(context);

                            await refresh();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Updated ✅")),
                            );
                          } catch (e) {
                            setStateDialog(() => saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Update failed: $e")),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    nameC.dispose();
    dosageC.dispose();
    notesC.dispose();
    timesC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(
            child: Text("No medicines yet.\nAdd from + tab."),
          );
        }

        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final m = items[i];
              final id = m['id'] as int;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(m['name']),
                  subtitle: Text(
                    "Dosage: ${m['dosage'] ?? ''}\nTimes/day: ${m['times_per_day']}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ UPDATE (Edit)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openEditDialog(m),
                      ),

                      // ✅ Extra action (Taken)
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await MedicineService.logTaken(id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Marked as taken ✅")),
                          );
                        },
                      ),

                      // ✅ DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await MedicineService.deleteMedicine(id);
                          refresh();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
