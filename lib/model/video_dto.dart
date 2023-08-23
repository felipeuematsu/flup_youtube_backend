import 'package:flup_youtube_backend/model/thumbnails.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_dto.freezed.dart';
part 'video_dto.g.dart';

@freezed
class VideoDto with _$VideoDto {
  const factory VideoDto({
    String? id,
    String? title,
    String? author,
    String? description,
    Duration? duration,
    int? viewCount,
    Thumbnails? thumbnails,
    DateTime? uploadDate,
  }) = _VideoDto;

  factory VideoDto.fromJson(Map<String, dynamic> json) => _$VideoDtoFromJson(json);
}
