import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? iconEmoji;

  @HiveField(3)
  final int colorThemeValue;

  @HiveField(4)
  final FrequencyType frequencyType;

  @HiveField(5)
  final Map<String, bool>? customFrequency;

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
  })  : id = id ?? Uuid().v4(),
        completedDates = completedDates ?? [];

  Habit copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    int? colorThemeValue,
    FrequencyType? frequencyType,
    Map<String, bool>? customFrequency,
    DateTime? startDate,
    List<DateTime>? completedDates,
    bool? markEmojiAsNull,
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

  // --- JSON Serialization ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconEmoji': iconEmoji,
      'colorThemeValue': colorThemeValue,
      'frequencyType': frequencyType.index, // Store enum as index
      'customFrequency': customFrequency,
      'startDate': startDate.toIso8601String(), // Store date as ISO string
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconEmoji: json['iconEmoji'] as String?,
      colorThemeValue: json['colorThemeValue'] as int,
      frequencyType: FrequencyType.values[json['frequencyType'] as int],
      customFrequency: (json['customFrequency'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)),
      startDate: DateTime.parse(json['startDate'] as String),
      completedDates: (json['completedDates'] as List<dynamic>)
          .map((dateString) => DateTime.parse(dateString as String))
          .toList(),
    );
  }
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
