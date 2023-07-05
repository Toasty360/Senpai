import 'package:flutter/material.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';

class trendingPage extends StatefulWidget {
  const trendingPage({super.key});

  @override
  State<trendingPage> createState() => _trendingPageState();
}

class _trendingPageState extends State<trendingPage> {
  static List<AnimeModel> topair = [];

  getTopAir() async {
    topair = await AniList.fetchTopAir();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (topair.isEmpty) {
      getTopAir();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: RawKeyboardListener(
            focusNode: FocusNode(),
            includeSemantics: true,
            autofocus: true,
            child: Cards(topair, "geners")));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
