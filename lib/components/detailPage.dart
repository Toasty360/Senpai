import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/services/gogoFetcher.dart';
import 'package:senpai/services/hanimeFetcher.dart';
import 'package:senpai/services/zoroFetcher.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';

class detailPage extends StatefulWidget {
  // final Map<String, String> data;
  final AnimeModel item;
  const detailPage(this.item, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _detailPageState createState() => _detailPageState();
}

class _detailPageState extends State<detailPage> {
  late AnimeModel anime;
  static var genreString = "";
  static Map<String, Map> tempAniDetails = {};
  String currentIndex = "";
  bool status = true;
  bool isLoaded = false;
  // late AnimeDetails? anime = AnimeDetails.dummydata();
  // late List<EpisodeModel> itemDetails;
  // List ZoroData = [];
  // AnimeDataController animedatacont = Get.put(AnimeDataController());
  bool isSaved = false;
  // int savedIndex = -1;
  late MeeduPlayerController _meeduPlayerController;
  late List media;
  bool isMediaReady = false;
  // final minCount = 4;
  late String streamer = "Gogoanime";
  // late String gogoid;
  List hentaiData = [];
  List watchedIndex = [];
  int watchedIndexMonitor = 0;

  fetchData() async {
    // print(widget.item.aniId);
    // print(widget.item.malId);
    // print(widget.item.title);

    if (widget.item.is_hentai) {
      fetchSequelhentai(widget.item.aniId).then((value) {
        // print(value);
        hentaiData = value;
        setState(() {});
      });
    } else if (widget.item.geners.toLowerCase().contains("hentai")) {
      await fetchInfoByTitle(widget.item.title).then((temp) {
        // print(temp);
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
              Toast.show("Not found in Zoro....trying to fetch from animepahe ",
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            } else {
              print('zoro has: ${temp.episodes.length}');
            }
            anime = temp;
          });
        }
        // if (anime.episodes.isEmpty) {
        //   await AniList.fetchInfo(widget.item.aniId, provider: "animepahe")
        //       .then((temp) {
        //     streamer = "animepahe";
        //     if (temp.episodes.isEmpty) {
        //       // print("No data from animepahe");
        //       Toast.show("Not found in animepahe....implement another source ",
        //           duration: Toast.lengthShort, gravity: Toast.bottom);
        //     } else {
        //       print('animepahe has: ${temp.episodes.length}');
        //     }
        //     anime = temp;
        //   });
        // }
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
      print(anime.episodes);
    }
    if (isSaved) {
      _saveItem();
    }
    setState(() {});
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
  final _WatchedIndexs = Hive.box("WatchedIndexs");

  Future<bool> _saveItem() async {
    try {
      await _watchList.put(anime.aniId, anime);
    } catch (e) {
      return false;
    }
    return true;
  }

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
    print("isSaved $isSaved");
    setState(() {});
  }

  getData() async {
    anime = await _watchList.get(anime.aniId);
  }

  getWatchedIndexs() async {
    watchedIndex = await _WatchedIndexs.get(anime.aniId) ?? [];
    watchedIndexMonitor = watchedIndex.length;
  }

  @override
  void initState() {
    super.initState();
    anime = widget.item;
    hasData();
    getWatchedIndexs();

    // if (tempAniDetails.containsKey(widget.item.title) &&
    //     anime.status.toLowerCase() == "completed") {
    //   print("saved data from tempaniDetails");
    //   anime = tempAniDetails[widget.item.title]!["Anilist"];
    //   streamer = tempAniDetails[widget.item.title]!["source"];
    // } else if (widget.item.status.toLowerCase().contains("not")) {
    //   print("No need to fetch the data ig");
    // } else {
    //   print("should fetch the data");
    //   fetchData();
    // }
    setState(() {});
  }

  Widget animeDetailsWidget(Size screen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          isMediaReady
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: MeeduVideoPlayer(
                        controller: _meeduPlayerController,
                      )),
                )
              : Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        opacity: 0.3,
                        colorFilter: const ColorFilter.srgbToLinearGamma(),
                        scale: 1.5,
                        image: NetworkImage(anime.cover, scale: 1.5),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          anime.title,
                          style: TextStyle(
                              color: Colors.amber.shade600,
                              fontWeight: FontWeight.bold,
                              // fontFamily: "Takota",
                              fontSize: 18,
                              letterSpacing: 1,
                              overflow: TextOverflow.clip),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  anime.image,
                                  width: 150,
                                ),
                              ),
                              Container(
                                width: 140,
                                // height: 150,
                                // decoration: BoxDecoration(
                                //     border: Border.all(width: 1),
                                //     ),
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            const Text("Status: "),
                                            Text(
                                              anime.status
                                                      .toLowerCase()
                                                      .contains("not")
                                                  ? "Not yet"
                                                  : anime.status,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 13,
                                                  color: status
                                                      ? Colors.green.shade900
                                                      : Colors.amber.shade400),
                                            ),
                                          ],
                                        )),
                                    const Divider(),
                                    const SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "Genres",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 100,
                                        child: Text(
                                          anime.geners,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.fade,
                                        )),
                                    const Divider(),
                                    SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            const Text("Total Eps : "),
                                            Text(anime.totalEpisodes,
                                                style: TextStyle(
                                                    color:
                                                        Colors.amber.shade400)),
                                          ],
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
          const Divider(),
          //synopsis
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              child: Text(
                anime.desc,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget episodesWidget() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount:
          (anime.is_hentai || anime.geners.toLowerCase().contains("hentai"))
              ? hentaiData.length
              : anime.episodes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF17203A),
              showDragHandle: true,
              isDismissible: true,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Wanna download?"),
                          TextButton(
                              onPressed: () {}, child: const Text("Aye!"))
                        ],
                      ),
                      FutureBuilder(
                        future: downloadLinks(anime.episodes[index].id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return GridView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemBuilder: (context, _index) {
                                var key = snapshot.data!.keys.toList()[_index];
                                return TextButton(
                                    onPressed: () {
                                      context.navigator.pop();
                                      convertM3U8toMP4(
                                        m3u8Url: snapshot.data![key],
                                        name: anime.episodes[index].title,
                                        title: anime.title,
                                      );
                                      Toast.show("Downloding Started!",
                                          duration: Toast.lengthShort);
                                    },
                                    child: Text(
                                        snapshot.data!.keys.toList()[_index]));
                              },
                            );
                          }
                          return Center();
                        },
                      )
                    ],
                  ),
                );
              },
            );
          },
          onTap: () {
            watchedIndex.add(index);
            !(anime.is_hentai || anime.geners.toLowerCase().contains("hentai"))
                ? Toast.show(
                    "Loading video: Episode ${anime.episodes[index].number}",
                    backgroundColor: const Color(0xFF17203A),
                    textStyle: const TextStyle(color: Colors.green),
                    duration: Toast.lengthShort,
                    gravity: Toast.bottom)
                : null;
            currentIndex = (anime.is_hentai ||
                    anime.geners.toLowerCase().contains("hentai"))
                ? hentaiData[index]["sources"][0]["url"]
                : anime.episodes[index].id;
            readyPlayer(currentIndex, index);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
                height: 150,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6)
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      opacity: watchedIndex.contains(index) ? 0.2 : 1,
                      colorFilter: const ColorFilter.srgbToLinearGamma(),
                      scale: 1.5,
                      image: NetworkImage(
                          (anime.is_hentai ||
                                  anime.geners.toLowerCase().contains("hentai"))
                              ? hentaiData[index]["poster"]
                              : anime.episodes[index].image,
                          scale: 1.5),
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
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      backgroundBlendMode: watchedIndex.contains(index)
                          ? BlendMode.dstOver
                          : BlendMode.darken,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black54),
                  child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(
                      (anime.is_hentai ||
                              anime.geners.toLowerCase().contains("hentai"))
                          ? hentaiData[index]["name"]
                          : anime.episodes[index].title,
                      style: const TextStyle(
                          color: Colors.green, overflow: TextOverflow.ellipsis),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      (anime.is_hentai ||
                              anime.geners.toLowerCase().contains("hentai"))
                          ? hentaiData[index]["id"].toString()
                          : anime.episodes[index].number.toString(),
                      style: TextStyle(
                          color: (anime.is_hentai ||
                                  anime.geners.toLowerCase().contains("hentai"))
                              ? Colors.greenAccent
                              : Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }

  Future<void> convertM3U8toMP4(
      {String m3u8Url =
          "https://assets.afcdn.com/video49/20210722/m3u8/lld/v_645516.m3u8",
      String name = "Empty",
      String title = "unknown"}) async {
    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();

    String animePath = (await Directory(
                "${((await Directory("/storage/emulated/0/Download/senpai/").create()).path)}/${title.split(' ')[0]}")
            .create())
        .path;
    // File file = File("$animePath/$name.mp4");
    // file.delete();
    File file = File("$animePath/${name.trim()}.mp4");
    await flutterFFmpeg
        .execute(
            '-i $m3u8Url -bsf:a aac_adtstoasc -vcodec copy -c copy ${file.path}')
        .then((value) {
      if (value == 0) {
        Toast.show("Download sucessful!");
        file.rename(name
            .replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "")
            .replaceAll(" ", "_"));
      } else {
        Toast.show("Download Failed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 50).toInt();
    final screen = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xFF17203A),
        appBar: AppBar(
          elevation: 1.0,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF17203A),
          title: Text(
            anime.title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                if (isSaved) {
                  isSaved = await _removeItem();
                } else {
                  isSaved = await _saveItem();
                }
                setState(() {});
              },
              icon: Icon(MdiIcons.bookmark),
              tooltip: isSaved ? "Remove?" : "Save for Later!",
              color: isSaved ? Colors.greenAccent : Colors.white,
            )
          ],
        ),
        body: screen.width >= 600
            ? Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: animeDetailsWidget(screen)),
                    anime.episodes.isNotEmpty || hentaiData.isNotEmpty
                        ? Expanded(flex: 1, child: episodesWidget())
                        : const Center()
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                    isMediaReady
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: MeeduVideoPlayer(
                                  controller: _meeduPlayerController,
                                )),
                          )
                        : Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  opacity: 0.3,
                                  colorFilter:
                                      const ColorFilter.srgbToLinearGamma(),
                                  scale: 1.5,
                                  image: NetworkImage(anime.cover, scale: 1.5),
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
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    anime.title,
                                    style: TextStyle(
                                        color: Colors.amber.shade600,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: "Takota",
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        overflow: TextOverflow.clip),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  backgroundColor:
                                                      const Color(0xFF17203A),
                                                  body: Center(
                                                    child: GestureDetector(
                                                      onVerticalDragEnd:
                                                          (details) => context
                                                              .navigator
                                                              .pop(),
                                                      child: Container(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        height:
                                                            screen.height * 0.6,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 20),
                                                        decoration: BoxDecoration(
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .black45,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                  blurRadius: 6)
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: NetworkImage(
                                                                    anime
                                                                        .image))),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            anime.image,
                                            width: screen.width * 0.35,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 140,
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                                width: double.infinity,
                                                child: Row(
                                                  children: [
                                                    const Text("Status: "),
                                                    Text(
                                                      anime.status
                                                              .toLowerCase()
                                                              .contains("not")
                                                          ? "Not yet aired"
                                                          : anime.status,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: status
                                                              ? Colors
                                                                  .greenAccent
                                                              : Colors
                                                                  .amberAccent),
                                                    ),
                                                  ],
                                                )),
                                            const Divider(),
                                            const SizedBox(
                                                child: Text(
                                              "Genres",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                            SizedBox(
                                                // width: screen.width * 0.3,
                                                height: 100,
                                                child: Text(
                                                  anime.geners,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 4,
                                                )),
                                            const Divider(),
                                            SizedBox(
                                                width: double.infinity,
                                                child: Row(
                                                  children: [
                                                    const Text("Total Eps : "),
                                                    Text(anime.totalEpisodes,
                                                        style: TextStyle(
                                                            color: Colors.amber
                                                                .shade400)),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                    const Divider(),
                    //synopsis
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        anime.desc,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const Divider(),
                    anime.episodes.isNotEmpty || hentaiData.isNotEmpty
                        ? episodesWidget()
                        : const Center(
                            child: Text("Dang no episodes found yet!!"),
                          ),
                  ]));
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
    String currentQuality = "";
    return quality;
  }

  readyPlayer(id, index) {
    String title =
        (anime.is_hentai || anime.geners.toLowerCase().contains("hentai"))
            ? hentaiData[index]["name"]
            : currentIndex.replaceAll("-", " ").capitalize ?? "";
    StreamingLinksModel response;
    Map quality = {};

    if (anime.is_hentai || anime.geners.toLowerCase().contains("hentai")) {
      print(id);
      _meeduPlayerController = MeeduPlayerController();
      _meeduPlayerController.setDataSource(
        DataSource(
          type: DataSourceType.network,
          source: id,
        ),
        autoplay: true,
      );
      isMediaReady = true;
      setState(() {});
    } else {
      //360p, 480p, 720p, 1080p, default, backup
      Future.microtask(() async {
        if (streamer == "Zoro") {
          response = await ZoroFetcher.fetchStreamingURl(id);
        } else {
          response = await GogoFetcher.fetchStreamingURl(id);
        }

        media = response.sources;
        for (Map e in media) {
          quality[e["quality"]] = e["url"];
        }
        String currentQuality = "";
        print(quality);
        // if (!isMediaReady) {
        _meeduPlayerController = MeeduPlayerController(
          showLogs: false,
          autoHideControls: true,
          manageWakeLock: true,
          header: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  isMediaReady = false;
                  // _meeduPlayerController.onFullscreenClose();
                  _meeduPlayerController.setFullScreen(false, context);
                  _meeduPlayerController.dispose();
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                title,
                style: const TextStyle(color: Colors.white),
              )),
          bottomRight: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PopupMenuButton(
                color: Colors.black,
                tooltip: "Quality",
                child: const Icon(Icons.quora_outlined),
                itemBuilder: (context) {
                  return List.generate(quality.length, (index) {
                    String _current = quality.keys.toList()[index];
                    return PopupMenuItem(
                        enabled: !(_current == settings.qualityChoice),
                        onTap: () {
                          currentQuality = quality[_current];
                          var duration =
                              _meeduPlayerController.sliderPosition.value;
                          print(
                              "duration ig ${_meeduPlayerController.sliderPosition.value}");
                          _meeduPlayerController.setDataSource(
                            DataSource(
                              type: DataSourceType.network,
                              source: currentQuality,
                            ),
                            autoplay: true,
                          );
                          settings.qualityChoice = _current;
                          _meeduPlayerController.goToFullscreen(context);
                          _meeduPlayerController.seekTo(duration);
                          print(
                              "Duration after ig ${_meeduPlayerController.sliderPosition.value}");
                          isMediaReady = true;
                          context.navigator.pop();
                          setState(() {});
                        },
                        child: Text(
                          _current,
                          style: TextStyle(
                              color: settings.qualityChoice == _current
                                  ? Colors.blueAccent
                                  : Colors.white),
                        ));
                  });
                },
              ),
              IconButton(
                  onPressed: () {
                    Duration temp = _meeduPlayerController.sliderPosition.value;
                    _meeduPlayerController
                        .seekTo(temp + const Duration(minutes: 1, seconds: 25));
                  },
                  tooltip: "Skip Openning",
                  icon: const Icon(Icons.double_arrow_rounded)),
              PopupMenuButton(
                color: Colors.black,
                tooltip: "Download",
                child: const Icon(Icons.download),
                itemBuilder: (context) {
                  return List.generate(quality.length, (index) {
                    String _current = quality.keys.toList()[index];
                    return PopupMenuItem(
                        onTap: () {
                          currentQuality = quality[_current];
                          context.navigator.pop();
                          convertM3U8toMP4(
                            m3u8Url: quality[_current],
                            name: anime.episodes[index].title,
                            title: anime.title,
                          );
                          Toast.show("Downloding Started!",
                              duration: Toast.lengthShort);
                        },
                        child: Text(
                          _current,
                          style: TextStyle(
                              color: settings.qualityChoice == _current
                                  ? Colors.blueAccent
                                  : Colors.white),
                        ));
                  });
                },
              ),
            ],
          ),
          enabledButtons: const EnabledButtons(
            videoFit: false,
            playBackSpeed: false,
            pip: true,
            rewindAndfastForward: true,
          ),
          pipEnabled: true,
          customIcons: const CustomIcons(
              minimize: Icon(
                Icons.fullscreen_exit,
                color: Colors.white,
              ),
              fullscreen: Icon(Icons.fullscreen_rounded, color: Colors.white),
              sound: Icon(Icons.volume_up_outlined, color: Colors.white),
              mute: Icon(Icons.volume_off_outlined, color: Colors.white)),
        );
        // }
        _meeduPlayerController.setDataSource(
          DataSource(
            type: DataSourceType.network,
            source: currentQuality != ""
                ? currentQuality
                : quality[settings.qualityChoice] ?? quality["default"],
          ),
          autoplay: true,
        );
        // ignore: use_build_context_synchronously
        _meeduPlayerController.goToFullscreen(context);
        isMediaReady = true;
        setState(() {});
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
    if (isMediaReady) {
      Future.microtask(() => {_meeduPlayerController.dispose()});
    }
    print("disposed");
  }
}
