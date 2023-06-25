import 'package:dio/dio.dart';

import 'package:senpai/data/anime.dart';

class ZoroFetcher {
  static String base_url = "https://toasty-kun.vercel.app";
  static String zoro = "https://zoro.to";

  static Future<StreamingLinksModel> fetchStreamingURl(id) async {
    print("$base_url/anime/zoro/watch?episodeId=$id");
    final response =
        await Dio().get("$base_url/anime/zoro/watch?episodeId=$id");

    return StreamingLinksModel(
        response.data["sources"], response.data["subtitles"]);
  }

  static Future<List> fetchEpisodeList(zoroid) async {
    final response = await Dio().get("$base_url/anime/zoro/info?id=$zoroid");
    return response.data["episodes"].reversed.toList();
  }
}



// final Response html = await Dio().get(
//       '${zoro}ajax/v2/episode/list/${data["Zoro"]}',
//       options: Options(
//         responseType: ResponseType.plain,
//       ),
//     );
//     List<Map> list = [];
//     for (Element i in parse(jsonDecode(html.data)['html'])
//         .getElementsByClassName('ssl-item  ep-item')) {
//       list.add({
//         "provider": 'zoro',
//         "provId": i.attributes['data-id']!,
//         "title": i.attributes['title']!,
//         "number": i.attributes['data-number']!,
//       });
//     }