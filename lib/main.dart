import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  final yt = YoutubeExplode();

  final video = await yt.videos.get("https://www.youtube.com/watch?v=Xty2gi5cMa8");
  final manifest = await yt.videos.streams.getManifest('https://www.youtube.com/watch?v=Xty2gi5cMa8');
  final audio = manifest.audioOnly;

  final dio = Dio();
  Response response;

  String rawTitle = video.title;
  String cleanTitle = "";

  for(var i = 0; i<rawTitle.length; i++){
    if(rawTitle[i] == ':') cleanTitle += '_';
    else if(rawTitle[i] == '|') cleanTitle += '_';
    else if(rawTitle[i] == '/') cleanTitle += '_';
    else cleanTitle += rawTitle;
  }

  response = await dio.download(
    '${audio.first.url.toString()}',
    (await getTemporaryDirectory()).path + "${(await getTemporaryDirectory()).path}/$cleanTitle.m4a",
  );
  print(response);
  print(video.title);
  print(manifest);

  final stream = yt.videos.streams.get(audio.first);
  yt.close();
}

