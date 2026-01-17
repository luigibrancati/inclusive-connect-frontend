// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  debugPrint('EventFromJson: $json');
  return Event(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    locationData: LocationData.fromJson(
      Map<String, dynamic>.from(json['locationData']),
    ),
    dateTime: json['dateTime'] as String,
    author: ContentAuthorPublic.fromJson(
      Map<String, dynamic>.from(json['author']),
    ),
    createdAt: json['createdAt'] as String,
    lastModifiedAt: json['lastModifiedAt'] as String,
    imageUrls:
        (json['imageUrls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'locationData': instance.locationData.toJson(),
  'dateTime': instance.dateTime,
  'author': instance.author.toJson(),
  'createdAt': instance.createdAt,
  'lastModifiedAt': instance.lastModifiedAt,
  'imageUrls': instance.imageUrls,
};
