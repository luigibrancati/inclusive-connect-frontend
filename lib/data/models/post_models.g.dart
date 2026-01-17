// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeInteraction _$LikeInteractionFromJson(Map<String, dynamic> json) =>
    LikeInteraction(
      id: (json['id'] as num).toInt(),
      author: UserReference.fromJson(Map<String, dynamic>.from(json['author'])),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$LikeInteractionToJson(LikeInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author.toJson(),
      'createdAt': instance.createdAt,
    };

CommentCreate _$CommentCreateFromJson(Map<String, dynamic> json) =>
    CommentCreate(
      contentType:
          $enumDecodeNullable(_$ContentTypeEnumMap, json['contentType']) ??
          ContentType.comment,
      body: json['body'] as String,
    );

Map<String, dynamic> _$CommentCreateToJson(CommentCreate instance) =>
    <String, dynamic>{
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'body': instance.body,
    };

const _$ContentTypeEnumMap = {
  ContentType.comment: 'comment',
  ContentType.post: 'post',
};

CommentPublic _$CommentPublicFromJson(Map<String, dynamic> json) =>
    CommentPublic(
      id: (json['id'] as num).toInt(),
      contentType:
          $enumDecodeNullable(_$ContentTypeEnumMap, json['contentType']) ??
          ContentType.comment,
      body: json['body'] as String,
      postId: json['postId'] as int,
      author: ContentAuthorPublic.fromJson(
        Map<String, dynamic>.from(json['author']),
      ),
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map(
                (e) => LikeInteraction.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          const [],
      createdAt: json['createdAt'] as String?,
      lastModifiedAt: json['lastModifiedAt'] as String?,
    );

Map<String, dynamic> _$CommentPublicToJson(CommentPublic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'body': instance.body,
      'postId': instance.postId,
      'author': instance.author.toJson(),
      'likes': instance.likes.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
      'lastModifiedAt': instance.lastModifiedAt,
    };

PostPublic _$PostPublicFromJson(Map<String, dynamic> json) => PostPublic(
  id: (json['id'] as num).toInt(),
  contentType:
      $enumDecodeNullable(_$ContentTypeEnumMap, json['contentType']) ??
      ContentType.post,
  title: json['title'] as String,
  body: json['body'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  audioUrl: json['audioUrl'] as String?,
  audioBackgroundColorHex: json['audioBackgroundColorHex'] as String?,
  author: ContentAuthorPublic.fromJson(
    Map<String, dynamic>.from(json['author']),
  ),
  likes:
      (json['likes'] as List<dynamic>?)
          ?.map((e) => LikeInteraction.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentPublic.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      const [],
  createdAt: json['createdAt'] as String?,
  lastModifiedAt: json['lastModifiedAt'] as String?,
);

Map<String, dynamic> _$PostPublicToJson(PostPublic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentType': _$ContentTypeEnumMap[instance.contentType]!,
      'title': instance.title,
      'body': instance.body,
      'imageUrls': instance.imageUrls,
      'audioUrl': instance.audioUrl,
      'audioBackgroundColorHex': instance.audioBackgroundColorHex,
      'author': instance.author.toJson(),
      'likes': instance.likes.map((e) => e.toJson()).toList(),
      'comments': instance.comments.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
      'lastModifiedAt': instance.lastModifiedAt,
    };

PostCreateBody _$PostCreateBodyFromJson(Map<String, dynamic> json) =>
    PostCreateBody(
      title: json['title'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$PostCreateBodyToJson(PostCreateBody instance) =>
    <String, dynamic>{'title': instance.title, 'body': instance.body};
