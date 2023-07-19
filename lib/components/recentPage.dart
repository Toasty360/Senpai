import 'dart:math';

import 'package:flutter/material.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';

class RecentEpisodes extends StatefulWidget {
  final ScrollController scrollController;
  final Future<List<AnimeModel>> data;
  const RecentEpisodes(
      {super.key, required this.scrollController, required this.data});

  @override
  State<RecentEpisodes> createState() => _RecentEpisodesState();
}

class _RecentEpisodesState extends State<RecentEpisodes> {
  static List<AnimeModel> list = [];
  int page = 1;
  static bool isLoaded = false;

  fetchdata() async {
    if (AniList.hasNextPage) {
      List<AnimeModel> data = await AniList.fetchRecent(page: page.toString());
      setState(() {
        list.isNotEmpty ? (list.addAll(data)) : (list = data);
        isLoaded = true;
        page += 1;
      });
    }
  }

  preFetch() async {
    await widget.data.then((value) {
      if (value.isNotEmpty) {
        list = value;
        isLoaded = true;
        page++;
      } else {
        fetchdata();
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    if (list.isEmpty) preFetch();
  }

  refreshData() async {
    if (AniList.hasNextPage) {
      List<AnimeModel> data = await AniList.fetchRecent(page: 1);
      setState(() {
        data.addAll(list);
        list = data.toSet().toList();
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF17203A),
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent &&
                AniList.hasNextPage &&
                isLoaded) {
              isLoaded = false;
              Future.microtask(
                () async {
                  fetchdata();
                },
              );
            }
            return true;
          },
          child: isLoaded
              ? RefreshIndicator(
                  onRefresh: () => refreshData(),
                  child: Cards(
                    scrollController: widget.scrollController,
                    list,
                    "",
                  ))
              : const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Please wait fetching the latest episodes!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ])),
        ),
        // floatingActionButton: FloatingActionButton(
        //     onPressed: () async {
        //       if (list != []) {
        //         page += 1;
        //       }
        //       List<RecentEps> data = await AnimeApi.getRecentEps("$page");
        //       setState(() {
        //         list.addAll(data);
        //       });
        //     },
        //     child: const Icon(Icons.format_list_bulleted_add)),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
