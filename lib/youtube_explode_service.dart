import 'dart:async';

import 'package:karaoke_request_api/karaoke_request_api.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const Duration expiration = Duration(seconds: 3000);

const Duration interval = Duration(seconds: 30);

class YoutubeExplodeService {
  final YoutubeExplode _yt = YoutubeExplode();

  YoutubeHttpClient httpClient = YoutubeHttpClient();

  var uuid = Uuid();
  final uuidMap = <String, MapEntry<DateTime, VideoSearchList>>{};

  late final Timer timer = Timer.periodic(interval, (_) {
    final now = DateTime.now();
    uuidMap.removeWhere((key, value) => now.difference(value.key) > expiration);
  });

  Future<SearchQueryResponse> search(String query) async {
    try {
      final requestUuid = uuid.v1();
      final VideoSearchList videoSearchList = await _yt.search.search(query);
      uuidMap[requestUuid] = MapEntry(DateTime.now(), videoSearchList);
      final response = SearchQueryResponse(
        uuid: requestUuid,
        content: videoSearchList.map((e) => e.toDto()).toList(),
        expiration: DateTime.now().add(expiration),
      );
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<SearchQueryResponse?> searchMore(String uuid) async {
    final videoSearchList = uuidMap[uuid];
    if (videoSearchList != null) {
      final searchResults = await videoSearchList.value.nextPage();
      if (searchResults != null) {
        uuidMap[uuid] = MapEntry(DateTime.now(), searchResults);
        final response = SearchQueryResponse(uuid: uuid, content: searchResults.map((e) => e.toDto()).toList(), expiration: DateTime.now().add(expiration));
        return response;
      }
    }
    return null;
  }

  Future<VideoManifestResponse> getManifest(String id) async {
    final videoData = await _yt.videos.streamsClient.getManifest(id);
    final VideoManifestResponse response = videoData.toDto();

    return response;
  }

  void dispose() {
    _yt.close();
  }
}
