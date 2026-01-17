// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      sender: ContentAuthorPublic.fromJson(
        Map<String, dynamic>.from(json['sender']),
      ),
      recipient: UserReference.fromJson(
        Map<String, dynamic>.from(json['recipient']),
      ),
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'sender': instance.sender.toJson(),
      'recipient': instance.recipient.toJson(),
      'createdAt': instance.createdAt,
      'isRead': instance.isRead,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.follow: 'follow',
  NotificationType.friendRequest: 'friend_request',
  NotificationType.friendAccept: 'friend_accept',
};
