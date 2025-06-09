import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Assuming uuid will be added or handled

part 'habit.g.dart'; // Hive generator will create this

@HiveType(typeId: 0)
class Habit extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? iconEmoji; // Optional

  @HiveField(3)
  final int colorThemeValue; // Store color as int

  @HiveField(4)
  final FrequencyType frequencyType;

  @HiveField(5)
  final Map<String, bool>? customFrequency; // e.g., {'Mon': true, 'Tue': false}

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final List<DateTime> completedDates;

  Habit({
    String? id,
    required this.name,
    this.iconEmoji,
    required this.colorThemeValue,
    required this.frequencyType,
    this.customFrequency,
    required this.startDate,
    List<DateTime>? completedDates,
  })  : this.id = id ?? Uuid().v4(), // Generate ID if not provided
        this.completedDates = completedDates ?? [];

  //copyWith method for immutability
  Habit copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    int? colorThemeValue,
    FrequencyType? frequencyType,
    Map<String, bool>? customFrequency,
    DateTime? startDate,
    List<DateTime>? completedDates,
    bool? markEmojiAsNull, // To explicitly set iconEmoji to null
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconEmoji: markEmojiAsNull == true ? null : iconEmoji ?? this.iconEmoji,
      colorThemeValue: colorThemeValue ?? this.colorThemeValue,
      frequencyType: frequencyType ?? this.frequencyType,
      customFrequency: customFrequency ?? this.customFrequency,
      startDate: startDate ?? this.startDate,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconEmoji,
        colorThemeValue,
        frequencyType,
        customFrequency,
        startDate,
        completedDates,
      ];
}

@HiveType(typeId: 1)
enum FrequencyType {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  custom,
}
