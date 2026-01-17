import 'package:json_annotation/json_annotation.dart';
import 'user_models.dart';

part 'post_models.g.dart';

enum ContentType {
  @JsonValue('comment')
  comment,
  @JsonValue('post')
  post,
}

@JsonSerializable()
class LikeInteraction {
  final int id;
  final UserReference author;
  final String createdAt;

  LikeInteraction({
    required this.id,
    required this.author,
    required this.createdAt,
  });

  factory LikeInteraction.fromJson(Map<String, dynamic> json) =>
      _$LikeInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$LikeInteractionToJson(this);
}

@JsonSerializable()
class CommentCreate {
  @JsonKey(defaultValue: ContentType.comment)
  final ContentType contentType;
  final String body;

  CommentCreate({this.contentType = ContentType.comment, required this.body});

  factory CommentCreate.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CommentCreateToJson(this);
}

@JsonSerializable()
class CommentPublic {
  final int id;
  @JsonKey(defaultValue: ContentType.comment)
  final ContentType contentType;
  final String body;
  final int postId;
  final ContentAuthorPublic author;
  final List<LikeInteraction> likes;
  final String? createdAt;
  final String? lastModifiedAt;

  CommentPublic({
    required this.id,
    this.contentType = ContentType.comment,
    required this.body,
    required this.postId,
    required this.author,
    this.likes = const [],
    this.createdAt,
    this.lastModifiedAt,
  });

  factory CommentPublic.fromJson(Map<String, dynamic> json) =>
      _$CommentPublicFromJson(json);
  Map<String, dynamic> toJson() => _$CommentPublicToJson(this);
}

@JsonSerializable()
class PostPublic {
  final int id;
  @JsonKey(defaultValue: ContentType.post)
  final ContentType contentType;
  final String title;
  final String?
  body; // Body can be nullable if it's just an image post? Validation says required in schema but description says optional in some contexts? Schema says required. Okay adhering to schema.
  final List<String> imageUrls;
  final String? audioUrl;
  final String?
  audioBackgroundColorHex; // Store hex color for audio visualization
  // final List<String>? imagePresignedUrls;
  final ContentAuthorPublic author;
  final List<LikeInteraction> likes;
  final List<CommentPublic> comments;
  final String? createdAt;
  final String? lastModifiedAt;

  PostPublic({
    required this.id,
    this.contentType = ContentType.post,
    required this.title,
    this.body,
    this.imageUrls = const [],
    this.audioUrl,
    this.audioBackgroundColorHex,
    // this.imagePresignedUrls,
    required this.author,
    this.likes = const [],
    this.comments = const [],
    this.createdAt,
    this.lastModifiedAt,
  });

  factory PostPublic.fromJson(Map<String, dynamic> json) =>
      _$PostPublicFromJson(json);
  Map<String, dynamic> toJson() => _$PostPublicToJson(this);
}

// For creating a post, it's multipart form data usually, but if there's a JSON body part:
@JsonSerializable()
class PostCreateBody {
  final String title;
  final String body;
  // images are handled as binary in multipart

  PostCreateBody({required this.title, required this.body});

  factory PostCreateBody.fromJson(Map<String, dynamic> json) =>
      _$PostCreateBodyFromJson(json);
  Map<String, dynamic> toJson() => _$PostCreateBodyToJson(this);
}
