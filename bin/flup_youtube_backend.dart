import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:flup_youtube_backend/youtube_explode_service.dart';

void main() async {
  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  var server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080, shared: true);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

final YoutubeExplodeService yt = YoutubeExplodeService();

Future<Response> _echoRequest(Request request) async {
  switch (request.url.path) {
    case 'youtube/search':
      final hasUuid = request.url.queryParameters.containsKey('uuid');
      if (hasUuid) {
        final search = await yt.searchMore(request.url.queryParameters['uuid'] ?? '');
        if (search == null) {
          return Response.badRequest(body: jsonEncode({'message': 'Invalid uuid'}), headers: {'Content-Type': 'application/json'}, encoding: utf8);
        }
        return Response.ok(jsonEncode(search.toJson()), encoding: utf8, headers: {'Content-Type': 'application/json'});
      } else {
        final search = await yt.search(request.url.queryParameters['query'] ?? '');
        return Response.ok(jsonEncode(search.toJson()), encoding: utf8, headers: {'Content-Type': 'application/json'});
      }
    case 'youtube/manifest':
      final search = await yt.getManifest(request.url.queryParameters['id'] ?? '');
      return Response.ok(jsonEncode(search), encoding: utf8, headers: {'Content-Type': 'application/json'});
  }
  return Response.notFound('Not Found');
}
