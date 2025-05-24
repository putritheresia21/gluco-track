import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import '../models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  
  @override  
  State<ProfilePage> createState() => profilePageState();
}

class profilePageState extends State<ProfilePage> {
  final formKey= GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  DateTime ? selectedBirthDate;
  Gender? selectedGender;

  bool isLoading = false;

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.year || (today.month == birthDate.month && today.day < birthDate.day)){
      age--;
    }
    return age;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate() || selectedBirthDate == null || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please Complete all fields")),
      );
      return;
    }
    setState(() => isLoading = true);
    
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final email = FirebaseAuth.instance.currentUser!.email ?? "";
      final int age = calculateAge(selectedBirthDate!);
      
      final UserProfile profile = UserProfile(
        uid: uid,
        username: usernameController.text.trim(),
        email: email,
        gender: selectedGender!,
        birthDate: selectedBirthDate!,
        age: age,
      );

      await FirebaseFirestore.instance.collection('users').doc(uid).set(profile.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile Saved Succesfully")),
      );
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => HomePage(
            userId: uid, 
            username: usernameController.text.trim(),
            ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
        int calculatedAge = calculateAge(picked);
        ageController.text = calculatedAge.toString();
      });
    }
  }

  @override  
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: "Username"),
                      validator: (val) => val == null || val.isEmpty ? "Username required" : null,
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      title: Text(selectedBirthDate == null
                          ? "Select Birth Date"
                          : "${selectedBirthDate!.toLocal()}".split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: pickDate,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: ageController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: "Age"),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<Gender>(
                      value: selectedGender,
                      items: Gender.values
                          .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.toShortString()),
                          ))
                          .toList(),
                      hint: Text("Select Gender"),
                      onChanged: (val) => setState(() => selectedGender = val),
                      validator: (val) => val == null ? "Gender required" : null,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: saveProfile,
                      child: Text("Save Profile"),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
