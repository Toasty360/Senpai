import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:senpai/components/MediaPlayer.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/services/gogoFetcher.dart';
import 'package:senpai/services/hanimeFetcher.dart';
import 'package:senpai/services/zoroFetcher.dart';
import 'package:toast/toast.dart';

class detailPage extends StatefulWidget {
  // final Map<String, String> data;
  final AnimeModel item;
  const detailPage(this.item, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _detailPageState createState() => _detailPageState();
}

class _detailPageState extends State<detailPage>
    with SingleTickerProviderStateMixin {
  late AnimeModel anime;
  static Map<String, Map> tempAniDetails = {};
  String currentIndex = "";
  bool status = true;
  bool isLoaded = false;
  bool isSaved = false;

  late List media;
  late String streamer = "Gogoanime";
  List hentaiData = [];
  List watchedIndex = [];
  int watchedIndexMonitor = 0;
  final ScrollController scrollController = ScrollController();
  List<String> episodesbars = [];
  int perPage = 10;
  List<EpisodeModel> _filteredEpisodes = [];

  Map<String, File> downloads = {};
  Map<String, double> currentDownloadings = {};

  fetchData() async {
    if (widget.item.is_hentai) {
      fetchSequelhentai(widget.item.aniId).then((value) {
        hentaiData = value;
        setState(() {});
      });
    } else if (widget.item.geners.toLowerCase().contains("hentai")) {
      await fetchInfoByTitle(widget.item.title).then((temp) {
        hentaiData = temp;
        setState(() {});
      });
    } else {
      if (anime.totalEpisodes != '0') {
        await AniList.fetchInfo(widget.item.aniId, provider: "gogoanime")
            .then((temp) {
          // itemDetails = temp.episodes;
          if (temp.episodes.isEmpty && widget.item.status != "Not yet aired") {
            Toast.show("Not found in Gogo....trying to fetch from zoro ",
                duration: Toast.lengthShort, gravity: Toast.bottom);
            print("No data from gogoanime");
          } else {
            print('gogoanime has: ${temp.episodes.length}');
          }
          isLoaded = true;
          anime = temp;
          status = anime.status == "Completed" ? true : false;
        });
        if (anime.episodes.isEmpty && widget.item.status != "Not yet aired") {
          await AniList.fetchInfo(widget.item.aniId, provider: "zoro")
              .then((temp) {
            streamer = "Zoro";
            if (temp.episodes.isEmpty) {
              // print("No data from zoro");
              Toast.show("Not found in Zoro....trying to fetch from animepahe",
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            } else {
              print('zoro has: ${temp.episodes.length}');
            }
            anime = temp;
          });
        }
        tempAniDetails[widget.item.title] = {
          "Anilist": anime,
          "source": streamer,
        };
      } else {
        await AniList.fetchInfo(widget.item.aniId).then((temp) {
          isLoaded = true;
          anime = temp;
          status = anime.status == "Completed" ? true : false;
        });
      }
      // print(anime.episodes);
    }
    Toast.show("Refreshed");

    if (isSaved) {
      _saveItem();
    }
    filterEpisodes();
    filterout();
    setState(() {
      //i=0 j=10 -.. first 10 initial data
    });
    // Future.delayed(const Duration(milliseconds: 5), () {});
    // var gogoid = anime.title.romaji
    //     .toLowerCase()
    //     .replaceAll(RegExp(r'[\[\]:!]'), "")
    //     .replaceAll(" ", '-');
    // await AniList.fetchFromMalId(anime.malId).then((data) async {
    //   print("for ${anime.malId} ---- $data");
    //   if (data.isEmpty) {
    //     ZoroData = await GogoFetcher.fetchEpisodeList(gogoid);
    //     streamer = "Gogoanime";
    //   } else {
    //     if (data["Gogoanime"] == null) {
    //       ZoroData = await ZoroFetcher.fetchEpisodeList(data["Zoro"]);
    //       streamer = "Zoro";
    //     } else {
    //       ZoroData = await GogoFetcher.fetchEpisodeList(data["Gogoanime"]);
    //       streamer = "Gogoanime";
    //     }
    //   }
    //   ZoroData = ZoroData.reversed.toList();
    //   tempAniDetails[widget.item.title.romaji] = {
    //     "Anilist": anime,
    //     "source": streamer,
    //     "ZoroData": ZoroData
    //   };
    //   print(ZoroData.length);
    //   setState(() {});
    // });
    // Future.delayed(const Duration(milliseconds: 5), () {});
  }

  final _watchList = Hive.box("Later");

  Future<bool> _saveItem() async {
    try {
      await _watchList.put(anime.aniId, anime);
    } catch (e) {
      return false;
    }
    return true;
  }

  getData() async {
    anime = await _watchList.get(anime.aniId);
  }

  final _WatchedIndexs = Hive.box("WatchedIndexs");

  Future<bool> _saveIndexs() async {
    try {
      await _WatchedIndexs.put(anime.aniId, watchedIndex);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> _removeItem() async {
    try {
      await _watchList.delete(anime.aniId);
    } catch (e) {
      return true;
    }
    return false;
  }

  hasData() async {
    isSaved = await _watchList.containsKey(anime.aniId);
    if (isSaved) {
      _animationController.forward();
    }
    if (anime.status.toLowerCase() == "completed") {
      if (tempAniDetails.containsKey(widget.item.title)) {
        print("saved data from tempaniDetails");
        anime = tempAniDetails[widget.item.title]!["Anilist"];
        streamer = tempAniDetails[widget.item.title]!["source"];
      } else if (!isSaved) {
        print("not saved so we should fetch the data");
        fetchData();
      } else {
        print("data from the watchList-- Hive");
        getData();
      }
    } else if (anime.status.toLowerCase().contains("not")) {
      print("No need to fetch the data ig");
    } else {
      print("anime not completed so we should fetch the Latest data");
      fetchData();
    }
    // _filteredEpisodes = anime.episodes;
    isLoaded = true;
    print("isSaved $isSaved");
    filterEpisodes();
    filterout();
  }

  getWatchedIndexs() async {
    watchedIndex = await _WatchedIndexs.get(anime.aniId) ?? [];
    watchedIndexMonitor = watchedIndex.length;
  }

  final TextEditingController _controller = TextEditingController();
  late final AnimationController _animationController;

  bool showmore = false;
  bool showtitle = false;

  @override
  void initState() {
    super.initState();
    anime = widget.item;
    hasData();
    getWatchedIndexs();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    scrollController.addListener(() {
      showtitle = scrollController.offset > 200;
      setState(() {});
    });
    setState(() {
      getDownloads();
    });
  }

  getDownloads() {
    try {
      List<File> downloadList = [];

      setState(() {
        downloadList = Directory(
                "/storage/emulated/0/Download/senpai/${anime.title.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(":", "").replaceAll(" ", "_")}")
            .listSync()
            .whereType<File>()
            .toList();
        for (File e in downloadList) {
          downloads[e.path.split("/").last.split(".")[0]] = e;
        }
        print("downloads ${downloads.length}");
      });
    } catch (e) {
      print(e);
    }
  }

  filterEpisodes() {
    episodesbars = [];
    try {
      setState(() {
        int length = anime.episodes.length;
        if (length > perPage) {
          int prev = 0;
          List.generate(length ~/ perPage, (index) {
            episodesbars.add("${prev + 1} - ${prev + perPage}");
            prev = prev + perPage;
          });
          if (length % perPage != 0) {
            episodesbars.add("${prev + 1} - $length");
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  filterout({int i = 0, int j = 10}) {
    setState(() {
      _filteredEpisodes =
          anime.episodes.getRange(i, min(anime.episodes.length, j)).toList();
    });
  }

  List<Widget> detailsPart(Size screen) {
    return [
      SizedBox(
        height: 300,
        child: Stack(
          children: [
            Container(
              width: screen.width,
              height: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image:
                    NetworkImage(anime.cover != "" ? anime.cover : anime.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  Container(
                      color: Colors.amber,
                      alignment: Alignment.center,
                      child: const Text(
                        'Whoops!',
                        style: TextStyle(fontSize: 20),
                      ));
                },
              )),
            ),
            Container(
              height: 210,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(23, 32, 58, 0),
                      Color.fromRGBO(23, 32, 58, 0.7),
                      Color.fromRGBO(23, 32, 58, 1),
                    ]),
              ),
              width: screen.width,
            ),
            // Positioned(
            //     right: 10,
            //     top: 60,
            //     child: isLoaded
            //         ? InkWell(
            //             child: Container(
            //             padding: const EdgeInsets.symmetric(
            //                 horizontal: 10, vertical: 5),
            //             decoration: BoxDecoration(
            //                 color: const Color.fromARGB(168, 104, 58, 183),
            //                 borderRadius: BorderRadius.circular(8)),
            //             child: Text(isSaved ? "Saved" : "WatchLater"),
            //           ))
            //         : const Center()),
            Positioned(
                bottom: 0,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    anime.image,
                    width: 150,
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.greenAccent,
                        alignment: Alignment.center,
                        child: const Text(
                          'Whoops!',
                          style: TextStyle(fontSize: 20),
                        )),
                  ),
                )),
            Positioned(
                bottom: 100,
                // right: 0,
                left: 183,
                child: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 2),
                  width: screen.width * 0.40,
                  child: Text(
                    anime.title,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                )),
            Positioned(
                bottom: 20,
                // right: 20,
                left: 183,
                child: SizedBox(
                  width: 150,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.deepPurple),
                          child: Text(
                              "Ep ${anime.episodes.length}/${anime.totalEpisodes}")),
                      Text(anime.type),
                      Text(
                        anime.subOrDub!.toUpperCase(),
                      ),
                      isLoaded
                          ? InkWell(
                              radius: 0,
                              onTap: () async {
                                if (isSaved) {
                                  isSaved = await _removeItem();
                                  _animationController.reverse();
                                } else {
                                  isSaved = await _saveItem();
                                  _animationController.forward();
                                }
                                setState(() {});
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 85,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        width: 1, color: Colors.white)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(isSaved ? "Saved" : "Later"),
                                    Lottie.network(
                                        "https://assets8.lottiefiles.com/packages/lf20_nF4sSU5agv.json",
                                        controller: _animationController,
                                        height: 30),
                                  ],
                                ),
                              ))
                          : const Center()
                    ],
                  ),
                )),
            Positioned(
              top: 10,
              right: 20,
              child: screen.width > 600
                  ? Container(
                      alignment: Alignment.centerRight,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(52, 68, 137, 255)),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        tooltip: "Close",
                      ),
                    )
                  : const Center(),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: anime.geners
              .split(",")
              .map((e) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.white)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(e),
                  ))
              .cast<Widget>()
              .toList(),
        ),
      ),
      isLoaded && anime.nextAiringEpisode != 0
          ? Container(
              width: screen.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text("Next Episode at:  "),
                  Expanded(
                    child: Text(
                      "${DateTime.fromMillisecondsSinceEpoch(anime.nextAiringEpisode! * 1000).toLocal()}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ))
          : const Center(),
      anime.desc != ""
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: screen.width,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                  SizedBox(
                    height: showmore
                        ? null
                        : anime.desc.length > 200
                            ? 100
                            : null,
                    child: Text(
                      anime.desc.trim(),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            )
          : const Center(),
      !showmore && anime.desc.length >= 200
          ? TextButton(
              onPressed: () {
                showmore = !showmore;
                setState(() {});
              },
              child: Text("More"))
          : const Center()
    ];
  }

  // List<Widget> animeDetailsWidget(Size screen) {
  //   return [
  //     Container(
  //         padding: const EdgeInsets.all(10),
  //         margin: const EdgeInsets.symmetric(vertical: 10),
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             image: DecorationImage(
  //               fit: BoxFit.cover,
  //               opacity: 0.3,
  //               colorFilter: const ColorFilter.srgbToLinearGamma(),
  //               scale: 1.5,
  //               image: NetworkImage(anime.cover, scale: 1.5),
  //               onError: (exception, stackTrace) {
  //                 Container(
  //                     color: Colors.amber,
  //                     alignment: Alignment.center,
  //                     child: const Text(
  //                       'Whoops!',
  //                       style: TextStyle(fontSize: 20),
  //                     ));
  //               },
  //             )),
  //         child: ListView(
  //           shrinkWrap: true,
  //           physics: const ClampingScrollPhysics(),
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(5),
  //               child: Text(
  //                 anime.title,
  //                 style: TextStyle(
  //                     color: Colors.amber.shade600,
  //                     fontWeight: FontWeight.bold,
  //                     // fontFamily: "Takota",
  //                     fontSize: 18,
  //                     letterSpacing: 1,
  //                     overflow: TextOverflow.clip),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.only(bottom: 5),
  //               child: Row(
  //                 children: [
  //                   InkWell(
  //                     onTap: () {
  //                       Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => Scaffold(
  //                               backgroundColor: const Color(0xFF17203A),
  //                               body: Center(
  //                                 child: GestureDetector(
  //                                   onVerticalDragEnd: (details) =>
  //                                       context.navigator.pop(),
  //                                   child: Container(
  //                                     alignment: Alignment.bottomCenter,
  //                                     height: screen.height * 0.6,
  //                                     margin: const EdgeInsets.symmetric(
  //                                         horizontal: 20),
  //                                     decoration: BoxDecoration(
  //                                         boxShadow: const [
  //                                           BoxShadow(
  //                                               color: Colors.black45,
  //                                               offset: Offset(0, 2),
  //                                               blurRadius: 6)
  //                                         ],
  //                                         borderRadius:
  //                                             BorderRadius.circular(12),
  //                                         image: DecorationImage(
  //                                             fit: BoxFit.cover,
  //                                             image:
  //                                                 NetworkImage(anime.image))),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ));
  //                     },
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(10.0),
  //                       child: Image.network(
  //                         anime.image,
  //                         width: screen.width *
  //                             (screen.width > 600
  //                                 ? screen.width > 900
  //                                     ? 0.15
  //                                     : 0.25
  //                                 : 0.35),
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     width: 140,
  //                     margin: const EdgeInsets.only(left: 10),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         SizedBox(
  //                             width: double.infinity,
  //                             child: Row(
  //                               children: [
  //                                 const Text("Status: "),
  //                                 Text(
  //                                   anime.status.toLowerCase().contains("not")
  //                                       ? "Not yet aired"
  //                                       : anime.status,
  //                                   style: TextStyle(
  //                                       fontSize: 13,
  //                                       color: status
  //                                           ? Colors.greenAccent
  //                                           : Colors.amberAccent),
  //                                 ),
  //                               ],
  //                             )),
  //                         const Divider(),
  //                         const SizedBox(
  //                             child: Text(
  //                           "Genres",
  //                           textAlign: TextAlign.left,
  //                           style: TextStyle(
  //                             color: Colors.blueAccent,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         )),
  //                         SizedBox(
  //                             // width: screen.width * 0.3,
  //                             height: 100,
  //                             child: Text(
  //                               anime.geners,
  //                               style: const TextStyle(color: Colors.white),
  //                               overflow: TextOverflow.fade,
  //                               maxLines: 4,
  //                             )),
  //                         const Divider(),
  //                         SizedBox(
  //                             width: double.infinity,
  //                             child: Row(
  //                               children: [
  //                                 const Text("Total Eps : "),
  //                                 Text(anime.totalEpisodes,
  //                                     style: TextStyle(
  //                                         color: Colors.amber.shade400)),
  //                               ],
  //                             )),
  //                       ],
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         )),
  //     const Divider(),
  //     //synopsis
  //     Container(
  //       margin: const EdgeInsets.only(bottom: 10),
  //       child: Column(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.only(top: 10),
  //             padding: const EdgeInsets.all(10),
  //             height: showmore ? null : 200,
  //             child: Text(
  //               anime.desc,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w200,
  //               ),
  //               softWrap: true,
  //               textAlign: TextAlign.justify,
  //               maxLines: 50,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //           InkWell(
  //             onTap: () {
  //               showmore = !showmore;
  //               setState(() {});
  //             },
  //             radius: 0,
  //             child: Container(
  //               padding: const EdgeInsets.only(right: 10),
  //               alignment: Alignment.centerRight,
  //               child: Text(
  //                 showmore ? "Show less" : "Show more",
  //                 style: const TextStyle(color: Colors.blueAccent),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //     const Divider(),
  //   ];
  // }

  List<Widget> episodesWidget(Size screen) {
    return anime.episodes.isNotEmpty || hentaiData.isNotEmpty
        ? [
            Container(
                width: screen.width * 0.7,
                margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 57, 96, 211),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    if (value != "") {
                      int pos = int.parse(value) - 1;
                      filterout(i: pos, j: pos + 10);
                    } else {
                      filterout();
                    }
                  },
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: "search episode",
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.search_rounded)),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: const Text(
                      "Episodes :",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  DropdownMenu(
                    inputDecorationTheme: const InputDecorationTheme(
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                    width: 150,
                    menuStyle: const MenuStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Color(0xFF17203A))),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 10, label: "10"),
                      DropdownMenuEntry(value: 15, label: "15"),
                      DropdownMenuEntry(value: 20, label: "20"),
                      DropdownMenuEntry(value: 30, label: "30"),
                      DropdownMenuEntry(value: -1, label: "All")
                    ],
                    hintText: "Per page",
                    onSelected: (value) {
                      perPage = value!;
                      if (value != -1) {
                        filterEpisodes();
                      } else {
                        // _filteredEpisodes = anime.episodes;
                        filterout();
                      }
                    },
                  )
                ],
              ),
            ),
            episodesbars.isNotEmpty && perPage != -1
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    height: 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: episodesbars.length,
                      itemBuilder: (context, index) {
                        String btn = episodesbars[index];
                        return InkWell(
                          radius: 0,
                          onTap: () {
                            List<String> _ = btn.split("-");
                            filterout(
                                i: max(int.parse(_[0]) - 1, 0),
                                j: int.parse(_[1]));
                            print("Cliked ${_filteredEpisodes.length}");
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 9),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(6),
                                color: const Color.fromARGB(255, 57, 96, 211)),
                            child: Text(btn),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screen.width >= 600 ? 3 : 1,
                    childAspectRatio: 16 / 9,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                scrollDirection: Axis.vertical,
                // padding: const EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: (anime.is_hentai ||
                        anime.geners.toLowerCase().contains("hentai"))
                    ? hentaiData.length
                    : _filteredEpisodes.length,
                itemBuilder: (context, index) {
                  String _t = _filteredEpisodes[index]
                      .title
                      .replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "")
                      .replaceAll(" ", "_");
                  // print(_t);
                  bool isdownloaded = downloads.keys.toList().contains(_t);
                  bool isdownloading =
                      currentDownloadings.keys.toList().contains(_t);
                  return InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(12),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF17203A),
                        showDragHandle: true,
                        isDismissible: true,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Wanna download?"),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text("iya!"))
                                  ],
                                ),
                                FutureBuilder(
                                  future: downloadLinks(
                                      _filteredEpisodes[index].id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4),
                                        itemBuilder: (context, _index) {
                                          var key = snapshot.data!.keys
                                              .toList()[_index];
                                          return TextButton(
                                              onPressed: () {
                                                context.navigator.pop();
                                                convertM3U8toMP4(
                                                  m3u8Url: snapshot.data![key],
                                                  name: _filteredEpisodes[index]
                                                      .title,
                                                  title: anime.title,
                                                );
                                                Toast.show(
                                                    "Downloding Started!",
                                                    duration:
                                                        Toast.lengthShort);
                                              },
                                              child: Text(snapshot.data!.keys
                                                  .toList()[_index]));
                                        },
                                      );
                                    }
                                    return const Center();
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    onTap: () {
                      if (isdownloaded) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MediaPlayer(
                                      isM3u8: false,
                                      videoFile: downloads[_t],
                                    )));
                      } else {
                        !(anime.is_hentai ||
                                anime.geners.toLowerCase().contains("hentai"))
                            ? Toast.show(
                                "Loading video: Episode ${_filteredEpisodes[index].number}",
                                backgroundColor: const Color(0xFF17203A),
                                textStyle: const TextStyle(color: Colors.green),
                                duration: Toast.lengthShort,
                                gravity: Toast.bottom)
                            : null;
                        currentIndex = (anime.is_hentai ||
                                anime.geners.toLowerCase().contains("hentai"))
                            ? hentaiData[index]["sources"][0]["url"]
                            : _filteredEpisodes[index].id;
                        watchedIndex.add(index);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaPlayer(
                                isM3u8: true,
                                id: _filteredEpisodes[index].id,
                                isHentai: false,
                              ),
                            ));
                        // readyPlayer(currentIndex, index);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          height: 200,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      _filteredEpisodes[index].image),
                                  fit: BoxFit.cover)),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 201,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(31, 27, 36, 0),
                                      Color.fromRGBO(31, 27, 36, 1),
                                    ])),
                            child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: const BoxDecoration(
                                    color: Color.fromRGBO(31, 27, 36, 0.3)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _filteredEpisodes[index].title,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _filteredEpisodes[index].description,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ))),
                        Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8)),
                                  color: Color.fromARGB(141, 68, 137, 255)),
                              child: Text(
                                _filteredEpisodes[index].number.toString(),
                                style:
                                    const TextStyle(color: Colors.greenAccent),
                              ),
                            )),
                        isdownloaded
                            ? Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8)),
                                      color: Color.fromARGB(141, 68, 137, 255)),
                                  child: const Icon(
                                    Icons.download_done,
                                    size: 20,
                                  ),
                                ))
                            : const Center()
                      ],
                    ),
                  );
                },
              ),
            )
          ]
        : [
            const Center(
              child: Text("Dang no episodes found yet!!"),
            )
          ];
  }

  Future<void> convertM3U8toMP4(
      {String m3u8Url =
          "https://assets.afcdn.com/video49/20210722/m3u8/lld/v_645516.m3u8",
      String name = "Empty",
      String title = "unknown"}) async {
    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
    final FlutterFFmpegConfig fmpegConfig = FlutterFFmpegConfig();

    String animePath = (await Directory(
                "/storage/emulated/0/Download/senpai/${title.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(":", "").replaceAll(" ", "_")}")
            .create(recursive: true))
        .path;
    File file = File(
        "$animePath/${name.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(" ", "_")}.mp4");
    String fileName =
        name.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(" ", "_");
    print("fileName ${file.path}");

    int totalDuration = 0;
    bool gotDuration = false;

    fmpegConfig.enableLogCallback((log) {
      String _log = log.message;
      print(_log);
      if (gotDuration && totalDuration == 0) {
        print("duration ig $_log");
        final List<String> timeParts = _log.split(':');
        final int hours = int.parse(timeParts[0]);
        final int minutes = int.parse(timeParts[1]);
        final int seconds = double.parse(timeParts[2]).round();

        totalDuration = hours * 3600 + minutes * 60 + seconds;
        print("got it $totalDuration");
      }
      gotDuration = _log.contains("Duration:");

      if (_log.contains('time=')) {
        final RegExp regExp = RegExp(r'time=(\d+:\d+:\d+)');
        final Match? match = regExp.firstMatch(_log);

        if (match != null) {
          final String time = match.group(1)!;
          final List<String> timeParts = time.split(':');
          final int hours = int.parse(timeParts[0]);
          final int minutes = int.parse(timeParts[1]);
          final int seconds = int.parse(timeParts[2]);

          final int totalSeconds = hours * 3600 + minutes * 60 + seconds;
          final double progress =
              ((totalSeconds / totalDuration) * 100).toPrecision(2);
          currentDownloadings[fileName] = progress;
          print('Conversion Progress: $progress%');
        }
      }
    });
    await flutterFFmpeg
        .execute(
            '-i $m3u8Url -bsf:a aac_adtstoasc -vcodec copy -c copy $animePath/${name.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(" ", "_")}.mp4')
        .then((value) {
      if (value == 0) {
        // currentDownloads.downloads[fileName] = true;
        Toast.show("Download sucessful!");
        getDownloads();
      } else {
        try {
          // file.delete();
        } catch (e) {
          print(e);
        }
        Toast.show("Download Failed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // ignore: prefer_const_constructors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent));
    return GestureDetector(
      // onHorizontalDragEnd: (details) {
      //   if (kIsWeb || screen.width > 600) Navigator.pop(context);
      // },
      child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color.fromRGBO(23, 32, 58, 1),
          appBar: showtitle
              ? AppBar(
                  backgroundColor: const Color.fromRGBO(23, 32, 58, 1),
                  title: Text(anime.title),
                )
              : null,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   surfaceTintColor: Colors.transparent,
          //   elevation: 0,
          //   title: InkWell(
          //     radius: 0,
          //     onTap: () {
          //       if (scrollController.hasClients) {
          //         scrollController.animateTo(0,
          //             duration:
          //                 const Duration(milliseconds: 500), //duration of scroll
          //             curve: Curves.fastOutSlowIn);
          //       }
          //     },
          //     child: Text(
          //       anime.title,
          //     ),
          //   ),
          //   actions: [
          //     screen.width >= 600
          //         ? Container(
          //             height: 50,
          //             width: 220,
          //             alignment: Alignment.center,
          //             child: ListTile(
          //                 title: const Text(
          //                   "Default Quality",
          //                   style: TextStyle(fontSize: 15),
          //                 ),
          //                 trailing: TextButton(
          //                   onPressed: () {
          //                     settings.qualityChoice == "default"
          //                         ? settings.qualityChoice = "360p"
          //                         : settings.qualityChoice = "default";
          //                     print(settings.qualityChoice);
          //                     setState(() {});
          //                   },
          //                   child: Text(
          //                     settings.qualityChoice == "default"
          //                         ? "High"
          //                         : "Low",
          //                     style: const TextStyle(color: Colors.blue),
          //                   ),
          //                 )))
          //         : const Center(),
          //     // InkWell(
          //     //   radius: 0,
          //     //   onTap: () async {
          //     //     if (isSaved) {
          //     //       isSaved = await _removeItem();
          //     //       _animationController.reverse();
          //     //     } else {
          //     //       isSaved = await _saveItem();
          //     //       _animationController.forward();
          //     //     }
          //     //     setState(() {});
          //     //   },
          //     //   child: Lottie.network(
          //     //       "https://assets8.lottiefiles.com/packages/lf20_nF4sSU5agv.json",
          //     //       controller: _animationController),
          //     // ),
          //     // IconButton(
          //     //   onPressed: () async {
          //     //     if (isSaved) {
          //     //       isSaved = await _removeItem();
          //     //     } else {
          //     //       isSaved = await _saveItem();
          //     //     }
          //     //     setState(() {});
          //     //   },
          //     //   icon: Icon(MdiIcons.bookmark),
          //     //   tooltip: isSaved ? "Remove?" : "Save for Later!",
          //     //   color: isSaved ? Colors.greenAccent : Colors.white,
          //     // )
          //   ],
          // ),
          body: Container(
            child: ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: [
                  ...detailsPart(screen),
                  // ...animeDetailsWidget(screen),
                  ...episodesWidget(screen)
                ]),
          )),
    );
  }

  Future<Map> downloadLinks(id) async {
    Map quality = {};
    StreamingLinksModel response;

    if (streamer == "Zoro") {
      response = await ZoroFetcher.fetchStreamingURl(id);
    } else {
      response = await GogoFetcher.fetchStreamingURl(id);
    }

    media = response.sources;
    for (Map e in media) {
      quality[e["quality"]] = e["url"];
    }
    return quality;
  }

  readyPlayer(id, index) {
    if (anime.is_hentai || anime.geners.toLowerCase().contains("hentai")) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MediaPlayer(isM3u8: true, m3u8Url: id, isHentai: true),
          ));
    } else {
      //360p, 480p, 720p, 1080p, default, backup
      Future.microtask(() async {
        StreamingLinksModel response;
        Map quality = {};

        if (streamer == "Zoro") {
          response = await ZoroFetcher.fetchStreamingURl(id);
        } else {
          response = await GogoFetcher.fetchStreamingURl(id);
        }

        for (Map e in response.sources) {
          quality[e["quality"]] = e["url"];
        }
        // ignore: use_build_context_synchronously
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => MediaPlayer(
        //         isM3u8: true,
        //         quality: quality,
        //         isHentai: false,
        //       ),
        //     ));
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    watchedIndex = watchedIndex.toSet().toList();
    if (watchedIndexMonitor != watchedIndex.length) {
      _saveIndexs().then((value) {
        print("indexes saved ig $value");
      });
    }
    print("disposed");
  }
}
