import 'package:json_annotation/json_annotation.dart';
import 'user_models.dart';

part 'notification_models.g.dart';

enum NotificationType {
  @JsonValue('follow')
  follow,
  @JsonValue('friend_request')
  friendRequest,
  @JsonValue('friend_accept')
  friendAccept,
}

@JsonSerializable()
class NotificationModel {
  final int id;
  final NotificationType type;
  final ContentAuthorPublic sender;
  // recipientId is usually enough for the backend/service logic,
  // but keeping it simple as just ID here or we could link to UserReference
  final UserReference recipient;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.sender,
    required this.recipient,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    int? id,
    NotificationType? type,
    ContentAuthorPublic? sender,
    UserReference? recipient,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
