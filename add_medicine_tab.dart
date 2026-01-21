import 'package:flutter/material.dart';
import 'package:richi1196/medicine_service.dart';
import 'input_field.dart';

class AddMedicineTab extends StatefulWidget {
  const AddMedicineTab({super.key});

  @override
  State<AddMedicineTab> createState() => _AddMedicineTabState();
}

class _AddMedicineTabState extends State<AddMedicineTab> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final dosageC = TextEditingController();
  final notesC = TextEditingController();
  final timesC = TextEditingController(text: "1");

  bool loading = false;
  String? msg;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      msg = null;
    });

    try {
      await MedicineService.addMedicine(
        name: nameC.text.trim(),
        dosage: dosageC.text.trim(),
        notes: notesC.text.trim(),
        timesPerDay: int.parse(timesC.text),
      );

      nameC.clear();
      dosageC.clear();
      notesC.clear();
      timesC.text = "1";

      setState(() => msg = "Medicine added ✅");
    } catch (e) {
      setState(() => msg = "Failed to add");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            InputField(
              controller: nameC,
              keyboardType: TextInputType.text,
              label: "Medicine Name",
              hint: "Napa",
              icon: Icons.medication,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: dosageC,
              keyboardType: TextInputType.text,
              label: "Dosage",
              hint: "500mg",
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: timesC,
              keyboardType: TextInputType.number,
              label: "Times per day",
              hint: "2",
              icon: Icons.timelapse,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: notesC,
              keyboardType: TextInputType.text,
              label: "Notes",
              hint: "After meal",
              icon: Icons.note,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Save"),
            ),
            if (msg != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  msg!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
