import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';

class trendingPage extends StatefulWidget {
  final ScrollController scrollController;
  const trendingPage({super.key, required this.scrollController});

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
    return topair.isNotEmpty
        ? Cards(scrollController: widget.scrollController, topair, "geners")
        : const Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Please wait fetching trending data!",
              style: TextStyle(color: Colors.white),
            ),
          ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
