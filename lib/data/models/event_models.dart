import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_models.dart';
import 'common_models.dart';

part 'event_models.g.dart';

@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String description;
  final LocationData locationData;
  final String dateTime;
  final ContentAuthorPublic author;
  final String createdAt;
  final String lastModifiedAt;
  final List<String> imageUrls;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.locationData,
    required this.dateTime,
    required this.author,
    required this.createdAt,
    required this.lastModifiedAt,
    this.imageUrls = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event copyWith({
    String? title,
    String? description,
    LocationData? locationData,
    String? dateTime,
    ContentAuthorPublic? author,
    String? lastModifiedAt,
    List<String>? imageUrls,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      locationData: locationData ?? this.locationData,
      dateTime: dateTime ?? this.dateTime,
      author: author ?? this.author,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
