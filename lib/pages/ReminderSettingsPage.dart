import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/ReminderRepository.dart';
import 'package:glucotrack_app/services/ReminderService.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:intl/intl.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  final ReminderRepository _repository = ReminderRepository();
  final ReminderService _service = ReminderService();

  List<GlucoseReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await _repository.getReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reminders: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reminders: $e')),
        );
      }
    }
  }

  Future<void> _toggleReminder(GlucoseReminder reminder) async {
    try {
      final newStatus = !reminder.isActive;
      await _repository.toggleReminder(reminder.id, newStatus);

      if (newStatus) {
        // Schedule the reminder
        await _service.scheduleReminder(
          reminderId: reminder.id,
          time: reminder.reminderTime,
          daysOfWeek: reminder.daysOfWeek,
          title: reminder.label,
        );
      } else {
        // Cancel the reminder
        await _service.cancelReminder(reminder.id);
      }

      await _loadReminders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle reminder: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(GlucoseReminder reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.cancelReminder(reminder.id);
      await _repository.deleteReminder(reminder.id);
      await _loadReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reminder: $e')),
        );
      }
    }
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReminderDialog(
        onSave: () => _loadReminders(),
      ),
    );
  }

  void _showEditReminderDialog(GlucoseReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => _ReminderDialog(
        reminder: reminder,
        onSave: () => _loadReminders(),
      ),
    );
  }

  String _getDaysString(List<int> days) {
    if (days.length == 7) return 'Every day';
    
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((d) => dayLabels[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBack: true,
      showHeader: true,
      title: 'Glucose Reminders',
      headerBackgroundColor: const Color(0xFF2C7796),
      headerForegroundColor: Colors.white,
      bodyBackgroundColor: Colors.white,
      actions: [
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Reminders List
                Expanded(
                  child: _reminders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return _buildReminderCard(reminder);
                          },
                        ),
                ),

                // Add Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showAddReminderDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C7796),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first reminder',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(GlucoseReminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(reminder.reminderTime),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (_) => _toggleReminder(reminder),
                  activeColor: const Color(0xFF2C7796),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: List.generate(7, (index) {
                final isSelected = reminder.daysOfWeek.contains(index);
                const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2C7796)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditReminderDialog(reminder),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C7796),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deleteReminder(reminder),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DIALOG FOR ADD/EDIT REMINDER
// ============================================================================

class _ReminderDialog extends StatefulWidget {
  final GlucoseReminder? reminder;
  final VoidCallback onSave;

  const _ReminderDialog({
    this.reminder,
    required this.onSave,
  });

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  final _repository = ReminderRepository();
  final _service = ReminderService();
  final _labelController = TextEditingController();

  late TimeOfDay _selectedTime;
  late Set<int> _selectedDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      // Edit mode
      _labelController.text = widget.reminder!.label;
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.reminderTime);
      _selectedDays = Set.from(widget.reminder!.daysOfWeek);
    } else {
      // Add mode
      _labelController.text = 'Glucose Reminder';
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      _selectedDays = {1, 2, 3, 4, 5}; // Weekdays by default
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2C7796),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2C7796)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _save() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.reminder != null) {
        // Update existing reminder
        await _repository.updateReminder(
          reminderId: widget.reminder!.id,
          reminderTime: reminderTime,
          daysOfWeek: _selectedDays.toList(),
          label: _labelController.text,
        );

        // Reschedule if active
        if (widget.reminder!.isActive) {
          await _service.cancelReminder(widget.reminder!.id);
          await _service.scheduleReminder(
            reminderId: widget.reminder!.id,
            time: reminderTime,
            daysOfWeek: _selectedDays.toList(),
            title: _labelController.text,
          );
        }
      } else {
        // Create new reminder
        final reminderId = await _repository.createReminder(
          reminderTime: reminderTime,
          daysOfWeek: _selectedDays.toList(),
          label: _labelController.text,
        );

        // Schedule it
        await _service.scheduleReminder(
          reminderId: reminderId,
          time: reminderTime,
          daysOfWeek: _selectedDays.toList(),
          title: _labelController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.reminder != null ? 'Reminder updated' : 'Reminder created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reminder: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.reminder != null ? 'Edit Reminder' : 'Add Reminder',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Label Input
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF2C7796)),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Day Selector
              const Text(
                'Repeat on',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays.contains(index);
                  
                  return InkWell(
                    onTap: () => _toggleDay(index),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2C7796)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          dayLabels[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C7796),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.reminder != null ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
