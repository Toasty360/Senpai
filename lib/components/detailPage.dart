import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/utils.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  int savedIndex = -1;
  final TextEditingController _controller = TextEditingController();
  late MeeduPlayerController _meeduPlayerController;
  late List media;
  bool isMediaReady = false;
  final minCount = 4;
  late String streamer = "Gogoanime";
  late String gogoid;
  List hentaiData = [];

  fetchData() async {
    print(widget.item.aniId);
    print(widget.item.malId);
    print(widget.item.title);

    if (widget.item.is_hentai ||
        widget.item.geners.toLowerCase().contains("hentai")) {
      fetchSequelhentai(widget.item.aniId).then((value) {
        print(value);
        hentaiData = value;
        setState(() {});
      });
    } else {
      // if (widget.item.geners.toLowerCase().contains("hentai")) {
      //   await haniList(widget.item.title.).then((temp) {
      //     print(temp);
      //   });
      // }
      if (anime.totalEpisodes != '0') {
        await AniList.fetchInfo(widget.item.aniId, provider: "gogoanime")
            .then((temp) {
          // itemDetails = temp.episodes;
          if (temp.episodes.isEmpty) {
            Toast.show("Not found in Gogo....trying to fetch from zoro ",
                duration: Toast.lengthShort, gravity: Toast.bottom);
            // print("No data from gogoanime");
          } else {
            print('gogoanime has: ${temp.episodes.length}');
          }
          isLoaded = true;
          anime = temp;
          status = anime.status == "Completed" ? true : false;
        });
        if (anime.episodes.isEmpty) {
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
        if (anime.episodes.isEmpty) {
          await AniList.fetchInfo(widget.item.aniId, provider: "animepahe")
              .then((temp) {
            streamer = "animepahe";
            if (temp.episodes.isEmpty) {
              // print("No data from animepahe");
              Toast.show("Not found in animepahe....implement another source ",
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            } else {
              print('animepahe has: ${temp.episodes.length}');
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

  // getIndexs() {
  //   for (var item in animedatacont.x) {
  //     if (item.animeTitle == widget.item.animeTitle) {
  //       isSaved = true;
  //       savedIndex = animedatacont.x.indexOf(item);
  //     }
  //   }
  // }
  final _watchList = Hive.box("Later");
  Future<bool> _saveItem() async {
    try {
      await _watchList.put(anime.aniId, anime);
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    anime = widget.item;
    hasData();
    gogoid = anime.title
        .toLowerCase()
        .replaceAll(RegExp(r'[\[\]:!,?<>%&@\(\)\{\}]'), "")
        .replaceAll(" ", '-');

    // getIndexs();
    if (tempAniDetails.containsKey(widget.item.title)) {
      anime = tempAniDetails[widget.item.title]!["Anilist"];
      streamer = tempAniDetails[widget.item.title]!["source"];
    } else {
      fetchData();
    }
    setState(() {});
    // print(gogoid);
    // var count = 0;
    // anime.episodes.forEach((element) {
    //   print('${element.number}--$count');
    //   count++;
    // });
    // print(count);
    // count = 0;
    // ZoroData.forEach((element) {
    //   print('${element["number"]}---$count');
    //   count++;
    // });
    // print(count);

    // print("anidata-${anime.episodes.length}");
    // print('ZoroData-${ZoroData.length}');
  }

  Widget animeDetailsWidget(Size screen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
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
                                              anime.status,
                                              style: TextStyle(
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
      physics: ClampingScrollPhysics(),
      itemCount: anime.is_hentai ? hentaiData.length : anime.episodes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            !anime.is_hentai
                ? Toast.show(
                    "Loading video: Episode ${anime.episodes[index].number}",
                    backgroundColor: const Color(0xFF17203A),
                    textStyle: TextStyle(
                        color: anime.color != ""
                            ? fromHex(anime.color!)
                            : Colors.green),
                    duration: Toast.lengthShort,
                    gravity: Toast.bottom)
                : null;
            currentIndex = anime.is_hentai
                ? hentaiData[index]["sources"][0]["url"]
                : anime.episodes[index].id;
            readyPlayer(currentIndex, index);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      opacity: 1,
                      colorFilter: const ColorFilter.srgbToLinearGamma(),
                      scale: 1.5,
                      image: NetworkImage(
                          anime.is_hentai
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
                  // margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black54),
                  child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(
                      anime.is_hentai
                          ? hentaiData[index]["name"]
                          : anime.episodes[index].title,
                      style: TextStyle(
                          color: anime.color != ""
                              ? fromHex(anime.color!)
                              : Colors.green,
                          overflow: TextOverflow.ellipsis),
                    ),
                    subtitle: Text(
                      anime.is_hentai
                          ? hentaiData[index]["id"].toString()
                          : anime.episodes[index].number.toString(),
                      style: TextStyle(
                          color: anime.is_hentai
                              ? Colors.greenAccent
                              : anime.cover != ""
                                  ? fromHex(anime.color!)
                                  : Colors.green),
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
            // TextButton(child: isSaved?Text("Saved") ,onPressed: ())
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
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
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
                                    image:
                                        NetworkImage(anime.cover, scale: 1.5),
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
                                physics: ClampingScrollPhysics(),
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
                                    child: Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                              anime.image,
                                              width: screen.width * 0.35,
                                            ),
                                          ),
                                          Container(
                                            width: 140,
                                            margin:
                                                const EdgeInsets.only(left: 10),
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
                                                          anime.status,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: status
                                                                  ? Colors.green
                                                                      .shade900
                                                                  : Colors.amber
                                                                      .shade400),
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
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 4,
                                                    )),
                                                const Divider(),
                                                SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                            "Total Eps : "),
                                                        Text(
                                                            anime.totalEpisodes,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .amber
                                                                    .shade400)),
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
                    ]),
              ));
  }

  readyPlayer(id, index) {
    String title = anime.is_hentai
        ? hentaiData[index]["name"]
        : currentIndex.replaceAll("-", " ").capitalize ?? "";

    if (!isMediaReady) {
      _meeduPlayerController = MeeduPlayerController(
        header: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                isMediaReady = false;
                _meeduPlayerController.onFullscreenClose();
                // _meeduPlayerController.setFullScreen(false, context);
                _meeduPlayerController.dispose();
                setState(() {});
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            )),
        enabledButtons: const EnabledButtons(
          videoFit: false,
          playBackSpeed: false,
          pip: true,
          rewindAndfastForward: true,
        ),
        pipEnabled: true,
      );
    }
    if (anime.is_hentai) {
      print(id);
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
      Future.microtask(() async {
        StreamingLinksModel response;
        if (streamer == "Zoro") {
          response = await ZoroFetcher.fetchStreamingURl(id);
        } else {
          response = await GogoFetcher.fetchStreamingURl(id);
        }
        // response = await GogoFetcher.fetchStreamingURl(id);

        media = response.sources;
        Map quality = {};
        for (Map e in media) {
          quality[e["quality"]] = e["url"];
        }
        print(quality);
        _meeduPlayerController.setDataSource(
          DataSource(
            type: DataSourceType.network,
            source: quality["1080"] ?? quality["default"],
          ),
          autoplay: true,
        );
        isMediaReady = true;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (isMediaReady) {
      Future.microtask(() => {_meeduPlayerController.dispose()});
    }
    // animedatacont.writeWatchlistToFile();
    print("disposed");
  }
}
