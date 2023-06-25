import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:senpai/data/anime.dart';

Future<dynamic> fetchSequelhentai(id) async {
  final Response v = await Dio().get(
    "https://hanime.tv/api/v8/video?id=$id",
  );
  Map data = v.data;
  List sequel = data["hentai_franchise_hentai_videos"];
  List sequelData = [];
  for (var e in sequel) {
    await haniList(e["id"]).then((value) {
      sequelData.add({
        "id": e["id"],
        "name": e["name"],
        "cover": e["cover_url"],
        "poster": e["poster_url"],
        "sources": value,
      });
    });
  }
  return sequelData;
}

Future<List> haniList(id) async {
  print("finding sources for $id");
  final Response v = await Dio().get(
    "https://hanime.tv/api/v8/video?id=$id",
  );

  List result = [];
  for (var e in v.data["videos_manifest"]["servers"][0]["streams"]) {
    if (e["url"] != "") {
      result.add({"quality": e["height"], "url": e["url"]});
    }
  }

  return result;
}

Future<List<AnimeModel>> HentaiHome({searchfor = ""}) async {
  Response json = await Dio().post(
    "https://search.htv-services.com/",
    data: jsonEncode(
      {
        "search_text": searchfor,
        "tags": [],
        "tags-mode": "AND",
        "brands": [],
        "blacklist": [],
        "order_by": "",
        "ordering": "",
        "page": 0
      },
    ),
  );
  List response = jsonDecode(json.data["hits"]);
  // print(response[""]);
  List<AnimeModel> data = [];
  for (Map e in response) {
    data.add(AnimeModel.toTopAir(e));
  }
  print('total hentai--${data.length}');
  // print(json.data["nbHits"]);
  // json.data["hits"].map((i)=>Hentai.fromjson(i)});
  return data;
}
