import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  String? _iconEmoji;
  late int _selectedColorIndex;
  late FrequencyType _frequencyType;
  late DateTime _startDate;

  bool get _isEditing => widget.habit != null;

  // Available icons for habits
  final List<String> _availableIcons = [
    '🏃‍♂️', '💧', '📚', '🧘‍♀️', '💪', '🌱', '🎯', '🎨',
    '🧠', '💤', '🥗', '🎵', '✍️', '💰', '📱', '🧹',
    '🚶‍♀️', '☕', '🌟', '🎪', '🔥', '⚡', '🌈', '✨'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _name = widget.habit!.name;
      _iconEmoji = widget.habit!.iconEmoji;
      _selectedColorIndex = widget.habit!.colorThemeValue % AppTheme.fluorescentColors.length;
      _frequencyType = widget.habit!.frequencyType;
      _startDate = widget.habit!.startDate;
    } else {
      _name = '';
      _iconEmoji = _availableIcons[0];
      _selectedColorIndex = 0;
      _frequencyType = FrequencyType.daily;
      _startDate = DateTime.now();
    }
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
        id: _isEditing ? widget.habit!.id : null,
        name: _name,
        iconEmoji: _iconEmoji,
        colorThemeValue: _selectedColorIndex,
        frequencyType: _frequencyType,
        startDate: _startDate,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppTheme.fluorescentColors[_selectedColorIndex],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Habit Name
              Text(
                'Habit Name',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _name,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Morning Run',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),

              const SizedBox(height: 32),

              // Choose an Icon
              Text(
                'Choose an Icon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = _iconEmoji == icon;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _iconEmoji = icon;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.fluorescentColors[_selectedColorIndex].withOpacity(0.2)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: AppTheme.fluorescentColors[_selectedColorIndex], width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Choose a Color
              Text(
                'Choose a Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppTheme.fluorescentColors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final color = entry.value;
                  final isSelected = _selectedColorIndex == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Frequency
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _FrequencyOption(
                    title: 'Daily',
                    subtitle: 'Every day',
                    isSelected: _frequencyType == FrequencyType.daily,
                    onTap: () => setState(() => _frequencyType = FrequencyType.daily),
                    color: AppTheme.fluorescentColors[_selectedColorIndex],
                  ),
                  const SizedBox(height: 12),
                  _FrequencyOption(
                    title: 'Weekly',
                    subtitle: 'Once a week',
                    isSelected: _frequencyType == FrequencyType.weekly,
                    onTap: () => setState(() => _frequencyType = FrequencyType.weekly),
                    color: AppTheme.fluorescentColors[_selectedColorIndex],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Start Date
              Text(
                'Start Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(_startDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.fluorescentColors[_selectedColorIndex],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Create Habit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.fluorescentColors[_selectedColorIndex],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _isEditing ? 'Update Habit' : 'Create Habit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

class _FrequencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FrequencyOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
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
