import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';

class trendingPage extends StatefulWidget {
  final ScrollController scrollController;
  final Future<List<AnimeModel>> topair;
  const trendingPage(
      {super.key, required this.scrollController, required this.topair});

  @override
  State<trendingPage> createState() => _trendingPageState();
}

class _trendingPageState extends State<trendingPage> {
  static List<AnimeModel> topair = [];
  static bool gotError = false;

  getTopAir() async {
    topair = await AniList.fetchTopAir();
    gotError = topair.isEmpty ? true : false;
    setState(() {});
  }

  preFetch() async {
    await widget.topair.then((value) {
      value.isNotEmpty ? topair = value : getTopAir();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    if (topair.isEmpty) preFetch();
  }

  @override
  Widget build(BuildContext context) {
    return topair.isNotEmpty
        ? SafeArea(
            child: Cards(
                scrollController: widget.scrollController, topair, "geners"))
        : !gotError
            ? const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Please wait fetching trending data!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ]))
            : Center(
                child: ElevatedButton(
                    onPressed: () {
                      getTopAir();
                    },
                    child: const Text("fetch?")),
              );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
