import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/custom_button.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:glucotrack_app/pages/GlucosePrediction.dart';
import 'package:glucotrack_app/pages/glucose_share_template.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';

class GlucoseMeasuring extends StatefulWidget {
  const GlucoseMeasuring({super.key});

  @override
  State<GlucoseMeasuring> createState() => GlucoseMeasuringState();
}

class GlucoseMeasuringState extends State<GlucoseMeasuring> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController glucoseController = TextEditingController();
  final Glucoserepository _repository = Glucoserepository();
  final _gamification = GamificationService.instance;

  double? glucoseLevel;
  GlucoseCondition selectedCondition = GlucoseCondition.beforeMeal;
  bool useCurrentTime = true;
  DateTime? selectedDateTime;
  bool isFromIoT = false;
  bool isLoading = false;

  @override
  void dispose() {
    glucoseController.dispose();
    super.dispose();
  }

  void clearForm() {
    setState(() {
      glucoseController.clear();
      glucoseLevel = null;
      selectedCondition = GlucoseCondition.beforeMeal;
      useCurrentTime = true;
      selectedDateTime = null;
      isFromIoT = false;
    });
  }

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

  Future<void> showShareDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C7796).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.share,
                  color: Color(0xFF2C7796),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.shareResult,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.shareResultMessage,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('no'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.no,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('yes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C7796),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.yesShare,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == 'yes') {
      final shareResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GlucoseShareTemplate(
            glucoseLevel: glucoseLevel!,
            condition: selectedCondition,
            timestamp: useCurrentTime ? DateTime.now() : selectedDateTime!,
            isFromIoT: isFromIoT,
          ),
        ),
      );

      if (shareResult == 'back' || shareResult == null) {
        clearForm();
      }
    } else if (result == 'no') {
      clearForm();
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    if (!useCurrentTime && selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.selectDateTimeFirst)),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get user ID from Supabase Auth
      final userId =
          SupabaseService.client.auth.currentUser?.id ?? 'default_user';

      final record = Glucoserecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        glucoseLevel: glucoseLevel!,
        timeStamp: useCurrentTime ? DateTime.now() : selectedDateTime!,
        condition: selectedCondition,
        isFromIoT: isFromIoT,
      );

      // Save to Supabase
      final success = await _repository.insertGlucoseRecord(record);

      if (success) {
        // Update gamification task
        if (isFromIoT) {
          await _gamification.incrementTaskProgress(TaskType.iotGlucose);
        } else {
          await _gamification.incrementTaskProgress(TaskType.manualGlucose);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.glucoseDataSaved),
              backgroundColor: Colors.green,
            ),
          );

          // Show share dialog after successful save
          await showShareDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedSaveDatabase),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedSaveData(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppLocalizations.of(context)!.glucoseRecord,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
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
              Text(
                AppLocalizations.of(context)!.glucoseLevelMgDl,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: glucoseController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 110,
                              top: 20,
                              bottom: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2C7796), width: 1.2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2C7796), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2C7796), width: 1.2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.glucoseLevelRequired;
                            }
                            if (double.tryParse(value) == null) {
                              return AppLocalizations.of(context)!.validNumberRequired;
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              glucoseLevel = double.tryParse(value!),
                        ),
                        Positioned(
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC3E3E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  // Navigasi ke halaman deteksi gula darah invasif dengan IoT
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Glucoseprediction(),
                                    ),
                                  );

                                  // Handle data from IoT measurement
                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    setState(() {
                                      glucoseController.text =
                                          result['glucoseLevel']
                                              .toStringAsFixed(1);
                                      glucoseLevel = result['glucoseLevel'];
                                      isFromIoT = result['isFromIoT'] ?? false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!.iotDataLoaded),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.automatic,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              if (isFromIoT)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sensors,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.iotDeviceData,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.measurementCondition,
                style: const TextStyle(
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
                        ? AppLocalizations.of(context)!.beforeMeal
                        : AppLocalizations.of(context)!.afterMeal),
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
                  Text(
                    AppLocalizations.of(context)!.useCurrentTime,
                    style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                  ),
                  child: Text(
                    selectedDateTime == null
                        ? AppLocalizations.of(context)!.selectDateTime
                        : "${AppLocalizations.of(context)!.dateTime}${selectedDateTime!.toLocal()}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 260),
              CustomButton(
                text: AppLocalizations.of(context)!.save,
                backgroundColor: const Color(0xFF2C7796),
                textColor: Colors.white,
                fontSize: 18,
                width: double.infinity,
                height: 60,
                borderRadius: 25,
                isLoading: isLoading,
                onPressed: isLoading ? () {} : submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
