import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/hanimeFetcher.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';

class Later extends StatefulWidget {
  const Later({super.key});

  @override
  State<Later> createState() => _LaterState();
}

class _LaterState extends State<Later> {
  List<AnimeModel> data = [];

  fetchHentaiHome({searchfor = ""}) async {
    HentaiHome(searchfor: searchfor).then((value) {
      data = value;
      print(value[0].image);
      setState(() {});
    });
  }

  // final _watchList = Hive.box("Later");
  // Future<void> _saveItem() async {
  //   await _watchList.put(1, {
  //     "name": "Toast",
  //     "age": "23",
  //     "cities": [
  //       {"USA": "Houston", "zip": "063"},
  //       {"ENG": "London", "zip": "045"}
  //     ]
  //   });
  //   print(_watchList.get(1));
  // }
  final _watchList = Hive.box("Later");
  Future<void> fetchLaterData() async {
    // await _watchList.
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchLaterData();
  }

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 250).toInt();
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF17203A),
      body: SafeArea(
        child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            children: [
              screen.width <= 600
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onDoubleTap: () {
                                      settings.toggleHentai();
                                      setState(() {});
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(
                                        settings.enableHentai
                                            ? "assets/images/female.jpg"
                                            : "assets/images/profilePic.jpg",
                                      ),
                                      minRadius: 30,
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, bottom: 8),
                              child: Text(
                                settings.enableHentai
                                    ? "Perverted weeb list"
                                    : "Weeb list!!",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: settings.enableHentai
                                        ? Colors.deepOrangeAccent
                                        : Colors.greenAccent),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, bottom: 8),
                              child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.sort),
                                  hoverColor: Colors.greenAccent,
                                  splashRadius: 10),
                            )
                          ]),
                    )
                  : const Center(),
              ValueListenableBuilder(
                valueListenable: _watchList.listenable(),
                builder: (context, value, child) {
                  var later = value.values.toList().cast<AnimeModel>();
                  List<AnimeModel> hentaiData = [];
                  List<AnimeModel> normalData = [];
                  for (AnimeModel e in later) {
                    e.is_hentai ? hentaiData.add(e) : normalData.add(e);
                  }
                  // later.map((e) {});
                  print(normalData.length);
                  return Cards(settings.enableHentai ? hentaiData : normalData,
                      "geners");
                },
              )
            ]),
      ),
    );
  }
}
