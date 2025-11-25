import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GlucoseMeasuring extends StatefulWidget {
  const GlucoseMeasuring({super.key});

  @override
  State<GlucoseMeasuring> createState() => GlucoseMeasuringState();
}

class GlucoseMeasuringState extends State<GlucoseMeasuring> {
  final formKey = GlobalKey<FormState>();
  double? glucoseLevel;
  GlucoseCondition selectedCondition = GlucoseCondition.beforeMeal;
  bool useCurrentTime = true;
  DateTime? selectedDateTime;

  Future<void> pickDateTime() async {
    final DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickDate != null) {
      final TimeOfDay? pickTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickDate.year,
            pickDate.month,
            pickDate.day,
            pickTime.hour,
            pickTime.minute,
          );
        });
      }
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    if (!useCurrentTime && selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pilih tanggal dan waktu terlebih dahulu.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Ambil userId atau gunakan default jika tidak ada
    String userId = prefs.getString('userId') ?? 'default_user';

    final record = Glucoserecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      glucoseLevel: glucoseLevel!,
      timeStamp: useCurrentTime ? DateTime.now() : selectedDateTime!,
      condition: selectedCondition,
    );

    try {
      // Ambil data yang sudah ada
      final String? recordsJson = prefs.getString('glucose_records');
      List<Map<String, dynamic>> records = [];

      if (recordsJson != null) {
        records = List<Map<String, dynamic>>.from(json.decode(recordsJson));
      }

      // Tambahkan record baru
      records.add(record.toMap());

      // Simpan kembali
      await prefs.setString('glucose_records', json.encode(records));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data glukosa berhasil disimpan.")),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF2C7796),
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Catatan Glukosa",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                iconSize: 30,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kadar Gula Darah (mg/dL)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2C7796), width: 1.2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kadar gula darah tidak boleh kosong";
                        }
                        if (double.tryParse(value) == null) {
                          return "Masukkan angka yang valid";
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          glucoseLevel = double.tryParse(value!),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Kondisi Waktu Pengukuran",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GlucoseCondition>(
                value: selectedCondition,
                items: GlucoseCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition == GlucoseCondition.beforeMeal
                        ? 'BeforeMeal'
                        : 'AfterMeal'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCondition = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2C7796), width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Gunakan Waktu Saat ini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: useCurrentTime,
                    onChanged: (value) {
                      setState(() {
                        useCurrentTime = value;
                      });
                    },
                    activeColor: const Color(0xFF2C7796),
                  ),
                ],
              ),
              if (!useCurrentTime)
                ElevatedButton(
                  onPressed: pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C7796),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    selectedDateTime == null
                        ? "Pilih Tanggal & Waktu"
                        : "Tanggal & Waktu: ${selectedDateTime!.toLocal()}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 300),
              Center(
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C7796),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
