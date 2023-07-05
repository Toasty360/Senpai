import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/services/hanimeFetcher.dart';
import 'package:senpai/settings.dart';

class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  static List<AnimeModel> data = [];
  final _controller = TextEditingController();
  var page = 1;
  bool goterror = false;
  bool isLoaded = false;
  bool isDataNew = false;
  late String currentSearch = "";
  final focus = FocusNode();

  getAnime(var value) async {
    print(page);
    await AniList.searchData(value.toString(), page: page).then((res) {
      print(res.length);
      isLoaded = true;
      data.addAll(res);
      page++;
      setState(() {});
    });
  }

  Widget loader = const Center(
    child: Text("Nothing to see here", style: TextStyle(color: Colors.white)),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent &&
              _controller.text.isNotEmpty &&
              AniList.searchHasNext &&
              isLoaded) {
            isLoaded = false;
            getAnime(currentSearch);
          }
          return true;
        },
        child: Container(
            color: const Color(0xFF17203A),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  Container(
                    height: 10,
                    color: Colors.transparent,
                  ),
                  Expanded(
                      child: data.isEmpty
                          ? goterror
                              ? const Center(
                                  child: Text("Nothing to see here",
                                      style: TextStyle(color: Colors.white)),
                                )
                              : Center(
                                  child: loader,
                                )
                          : Cards(data, "geners")),
                ])),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
