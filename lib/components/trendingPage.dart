import 'dart:math';

import 'package:flutter/material.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:shimmer/shimmer.dart';

class trendingPage extends StatefulWidget {
  const trendingPage({super.key});

  @override
  State<trendingPage> createState() => _trendingPageState();
}

class _trendingPageState extends State<trendingPage> {
  static List<AnimeModel> topair = [];
  static bool istopAirReady = false;
  // Widget topAirCards;

  getTopAir() async {
    print("called the data");
    topair = await AniList.fetchTopAir();
    istopAirReady = true;
    setState(() {});
    // topair
    //     .map((item) => )
    //     .toList();
  }

  @override
  void initState() {
    super.initState();
    if (topair.isEmpty) {
      getTopAir();
    }
    // print(context.orientation);
  }

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 300).toInt();
    final screen = MediaQuery.of(context).size;
    const minCount = 4;
    return SafeArea(child: Cards(topair, "geners"));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
