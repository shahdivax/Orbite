import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit; // Null if adding a new habit, non-null if editing

  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  String? _iconEmoji;
  late Color _currentColor; // For color picker
  late FrequencyType _frequencyType;
  late DateTime _startDate;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _name = widget.habit!.name;
      _iconEmoji = widget.habit!.iconEmoji;
      _currentColor = Color(widget.habit!.colorThemeValue);
      _frequencyType = widget.habit!.frequencyType;
      _startDate = widget.habit!.startDate;
    } else {
      _name = '';
      _iconEmoji = ''; // Default emoji or leave empty
      _currentColor = Colors.blueAccent; // Default color
      _frequencyType = FrequencyType.daily;
      _startDate = DateTime.now();
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() => _currentColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Done'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newHabit = Habit(
        id: _isEditing ? widget.habit!.id : null, // Keep old ID if editing
        name: _name,
        iconEmoji: _iconEmoji,
        colorThemeValue: _currentColor.value,
        frequencyType: _frequencyType,
        startDate: _startDate,
        // customFrequency and completedDates will be handled by notifier or default
        completedDates: _isEditing ? widget.habit!.completedDates : [],
      );

      final notifier = ref.read(habitsProvider.notifier);
      if (_isEditing) {
        notifier.updateHabit(newHabit);
      } else {
        notifier.addHabit(newHabit);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'Add New Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _iconEmoji,
                decoration: const InputDecoration(
                  labelText: 'Icon/Emoji (Optional)',
                  hintText: 'e.g., ✨ or 🚀',
                ),
                onSaved: (value) => _iconEmoji = value,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Habit Color:'),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Frequency:', style: Theme.of(context).textTheme.titleMedium),
              RadioListTile<FrequencyType>(
                title: const Text('Daily'),
                value: FrequencyType.daily,
                groupValue: _frequencyType,
                onChanged: (FrequencyType? value) {
                  setState(() {
                    _frequencyType = value!;
                  });
                },
              ),
              RadioListTile<FrequencyType>(
                title: const Text('Weekly'),
                value: FrequencyType.weekly,
                groupValue: _frequencyType,
                onChanged: (FrequencyType? value) {
                  setState(() {
                    _frequencyType = value!;
                  });
                },
              ),
              // TODO: Add UI for Custom Frequency if selected
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Start Date: ${DateFormat.yMMMd().format(_startDate)}', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickStartDate,
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save Changes' : 'Create Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
