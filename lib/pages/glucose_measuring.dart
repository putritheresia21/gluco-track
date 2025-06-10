import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Pilih Tanggal dan Waktu terlebih dahulu."),
      ));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User belum login."),
      ));
      return;
    }

    final Record = Glucoserecord(
      id: '', 
      userId: userId, 
      glucoseLevel: glucoseLevel!, 
      timeStamp: useCurrentTime ? DateTime.now() : selectedDateTime!, 
      condition: selectedCondition,
    );
    
    try {
      await FirebaseFirestore.instance
          .collection('glucose_records')
          .add(Record.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data glukosa berhasil disimpan."),
      ));
      Navigator.pop(context);
    } catch (e) {
      print('Error saat menyimpan: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menyimpan data: $e"),
      ));
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catatan Glukosa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Kadar Gula Darah (mg/dL)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Kadar gula darah tidak boleh kosong";
                  if (double.tryParse(value) == null) return "Masukkan angka yang valid";
                  return null;
                },
                onSaved: (value) => glucoseLevel = double.tryParse(value!),
              ),
              DropdownButtonFormField<GlucoseCondition>(
                value: selectedCondition,
                items: GlucoseCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition == GlucoseCondition.beforeMeal ? 'Sebelum Makan' : 'Setelah Makan'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCondition = value;
                    });
                  }
                },
                decoration: InputDecoration(labelText: "Kondisi Waktu Pengukuran"),
              ),
              SwitchListTile(
                title: Text("Gunakan Waktu Saat Ini"),
                value: useCurrentTime,
                onChanged: (value) {
                  setState(() {
                    useCurrentTime = value;
                  });
                },
              ),
              if (!useCurrentTime)
                ElevatedButton(
                  onPressed: pickDateTime,
                  child: Text(selectedDateTime == null 
                    ? "Pilih Tanggal & Waktu" 
                    : "Tanggal dan Waktu: ${selectedDateTime!.toLocal()}"),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!useCurrentTime && selectedDateTime == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Pilih tanggal dan Waktu"))
                    );
                    return;
                  }
                  submit();
                },
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
