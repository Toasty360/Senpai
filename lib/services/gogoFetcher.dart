import 'package:dio/dio.dart';
import 'package:senpai/data/anime.dart';

class GogoFetcher {
  static String base_url = "https://toasty-kun.vercel.app";

  static Future<List> fetchEpisodeList(gogoid) async {
    print("$base_url/anime/gogoanime/info/$gogoid");
    final response = await Dio().get("$base_url/anime/gogoanime/info/$gogoid");
    return response.data["episodes"].reversed.toList();
  }

  static Future<StreamingLinksModel> fetchStreamingURl(id) async {
    print("$base_url/anime/gogoanime/watch/$id");
    final response = await Dio().get("$base_url/anime/gogoanime/watch/$id");

    return StreamingLinksModel(
        response.data["sources"], response.data["subtitles"] ?? []);
  }
}
