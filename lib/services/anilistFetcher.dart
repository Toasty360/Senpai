import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:senpai/data/anime.dart';

class AniList {
  static String base_url = "https://toasty-kun.vercel.app/";

  static Future<List<AnimeModel>> fetchTopAir() async {
    print("called for trending");
    final response = await Dio().get("$base_url/meta/anilist/trending");
    // var data = jsonDecode(response.data["results"]);
    List data = response.data["results"];

    // print(data.length);

    List<AnimeModel> trending = [];
    for (var anime in data) {
      trending.add(AnimeModel.toTopAir(anime));
    }
    print("at trending ${trending.length}");

    return trending;
  }

  static bool hasNext = true;

  static Future<List<ScheduleModel>> fetchSchedule({page = 1}) async {
    print("called for schedule");
    List<ScheduleModel> data = [];
    const String queryString =
        """query (\$weekStart: Int,\$weekEnd: Int,\$page: Int,){
    Page(page: \$page) {
      pageInfo {
        hasNextPage
        total
      }
      airingSchedules(
        airingAt_greater: \$weekStart
        airingAt_lesser: \$weekEnd
        ) {
          id
          episode
          airingAt
          media 
          {
            id
            idMal
            title {
              romaji
              native
              english
            }
            type
            startDate {
              year
              month
              day
            }
            endDate {
                year
                month
                day
              }
                status
                season
                format
                genres
                synonyms
                duration
                popularity
                episodes
                source(version: 2)
                countryOfOrigin
                hashtag
                siteUrl
                description
                bannerImage
                isAdult
                coverImage {
                  extraLarge
                  color
                }
                trailer {
                  id
                  site
                  thumbnail
                }
                rankings {
                  rank
                  type
                  season
                  allTime
                }
            }
          }
        }
      }""";
    if (hasNext) {
      final client = GraphQLClient(
        cache: GraphQLCache(),
        link: HttpLink("https://graphql.anilist.co/"),
      );
      var time = DateTime.now();
      QueryResult query = await client
          .query(QueryOptions(document: gql(queryString), variables: {
        'weekStart': (time.millisecondsSinceEpoch / 1000).ceil(),
        'weekEnd':
            (time.add(const Duration(days: 6)).millisecondsSinceEpoch / 1000)
                .ceil(),
        'page': page,
      }));
      try {
        hasNext = query.data?["Page"]["pageInfo"]["hasNextPage"] ?? false;

        for (Map e in query.data?["Page"]["airingSchedules"]) {
          data.add(ScheduleModel.fromJson(e));
        }
      } catch (e) {
        print(e);
      }
      print("at schedule ${data.length}");

      return data;
    }
    return [];
  }

  static Future<AnimeModel> fetchInfo(id, {provider = ""}) async {
    print(id);

    final response =
        await Dio().get("$base_url/meta/anilist/info/$id?provider=$provider");
    return AnimeModel.toTopAir(response.data);
  }

  static bool hasNextPage = true;

  static Future<List<AnimeModel>> fetchRecent({page = 1}) async {
    if (hasNextPage) {
      print("called for Latest");
      final response =
          await Dio().get("$base_url/meta/anilist/recent-episodes?page=$page",
              options: Options(
                validateStatus: (status) => true,
              ));
      List<AnimeModel> data = [];
      for (Map e in response.data["results"]) {
        data.add(AnimeModel.toTopAir(e));
      }
      print("at latest ${data.length}");
      hasNextPage = response.data["hasNextPage"] ?? false;
      return data;
    }
    return [];
  }

  // static Future<AnimeModel> searchAnime(name) async {
  //   final response = await Dio().get("$base_url/meta/anilist/info/$name");
  //   return AnimeModel.toTopAir(response.data);
  // }
  // static Future<Map> fetchMappingsWithMal(malid, aniid) async {
  //   Map data;
  //   try {
  //     if()
  //     final response =
  //         await Dio().get("https://api.malsync.moe/mal/anime/$malid");
  //     if (response.statusCode == 404) {
  //       final response = await Dio().get(
  //           "https://raw.githubusercontent.com/MALSync/MAL-Sync-Backup/master/data/myanimelist/anime/$aniid.json");
  //       data = jsonDecode(response.data)["Sites"];
  //     } else {
  //       data = jsonDecode(response.data)["Pages"];
  //     }
  //     if (response.statusCode != 404) {
  //       Map<String, String> mappings = {};
  //       data.forEach((key, value) {
  //         mappings[key] =
  //             data[key][data[key].keys.first]["url"].split("/").removeLast();
  //       });
  //       print(mappings);
  //       return mappings;
  //     }
  //     return {};
  //   } catch (e) {
  //     e.printError();
  //     return {};
  //   }
  // }

  static Future<Map> fetchMappings(id) async {
    try {
      final response = await Dio().get(
          "https://raw.githubusercontent.com/MALSync/MAL-Sync-Backup/master/data/myanimelist/anime/$id.json");

      if (response.statusCode != 404) {
        Map data = jsonDecode(response.data)["Pages"];
        Map<String, String> mappings = {};
        data.forEach((key, value) {
          mappings[key] =
              data[key][data[key].keys.first]["url"].split("/").removeLast();
        });
        return mappings;
      }
      return {};
    } catch (e) {
      e.printError();
      return {};
    }
  }

  static Future<Map> fetchFromMalId(malid) async {
    try {
      final response =
          await Dio().get("https://api.malsync.moe/mal/anime/$malid");
      if (response.statusCode != 404) {
        Map data = response.data["Sites"];
        Map<String, String> mappings = {};
        data.forEach((key, value) {
          mappings[key] =
              data[key][data[key].keys.first]["url"].split("/").removeLast();
        });
        return mappings;
      }
      return {};
    } catch (e) {
      e.printError();
      return {};
    }
  }

  static bool searchHasNext = true;
  static Future<List<AnimeModel>> searchData(search, {page = 1}) async {
    final response =
        await Dio().get("$base_url/meta/anilist/$search?page=$page");
    List<AnimeModel> data = [];
    for (Map e in response.data["results"]) {
      data.add(AnimeModel.toTopAir(e));
    }
    print("total anilist---${data.length}");
    searchHasNext = response.data["hasNextPage"];
    return data;
  }

  static Future<AnimeModel> randomAnime() async {
    final response = await Dio().get("$base_url/meta/anilist/random-anime");

    return AnimeModel.toTopAir(response.data);
  }

  static bool advSearchHasNext = true;
  static Future<List<AnimeModel>> advancedSearch(List<String> genres,
      {page = "1"}) async {
    String qry = "";
    if (genres.isNotEmpty) {
      String gn = genres
          .toString()
          .replaceAll(" ", "")
          .replaceAll(",", '","')
          .replaceAll("[", '["')
          .replaceAll("]", '"]');
      qry = "&genres=$gn";
    }
    print("$base_url/meta/anilist/advanced-search?page=$page$qry");

    List<AnimeModel> data = [];
    final res =
        await Dio().get('$base_url/meta/anilist/advanced-search?page=$page$qry',
            options: Options(
              validateStatus: (status) => true,
            ));
    for (Map e in res.data["results"]) {
      data.add(AnimeModel.toTopAir(e));
    }
    advSearchHasNext = res.data["hasNextPage"];

    print(data.length);
    return data;
  }

  static Future<List> fetchSteamingLinks(String id) async {
    final v = await Dio().get("$base_url/meta/anilist/watch/$id",
        options: Options(
            receiveTimeout: Duration(seconds: 2),
            sendTimeout: Duration(milliseconds: 2)));
    return v.data["sources"];
  }
}
