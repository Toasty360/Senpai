import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';

class Later extends StatefulWidget {
  const Later({super.key});

  @override
  State<Later> createState() => _LaterState();
}

class _LaterState extends State<Later> {
  late MeeduPlayerController _meeduPlayerController;
  bool isReady = false;

  Map<String, List<File>> downloadData = {};

  Future<void> fetchAllDownloads() async {
    List<Directory> animeList =
        Directory("/storage/emulated/0/Download/senpai/")
            .listSync(recursive: false)
            .whereType<Directory>()
            .toList();

    Map<String, List<File>> downloads = {};

    for (Directory e in animeList) {
      downloads[e.path.split("/").last] =
          e.listSync().whereType<File>().toList();
    }
    setState(() {
      downloadData = downloads;
    });
  }

  Widget listItems() {
    return Container(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: Hive.box("Later").listenable(),
        builder: (context, value, child) {
          var later = value.values.toList().cast<AnimeModel>();
          List<AnimeModel> hentaiData = [];
          List<AnimeModel> normalData = [];
          for (AnimeModel e in later) {
            e.is_hentai || e.geners.toLowerCase().contains("hentai")
                ? hentaiData.add(e)
                : normalData.add(e);
          }
          return Cards(
              settings.enableHentai ? hentaiData : normalData, "geners");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return SafeArea(
        child: screen.width <= 600
            ? ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onTap: () {
                                      fetchAllDownloads();
                                      showModalBottomSheet(
                                        showDragHandle: true,
                                        backgroundColor:
                                            const Color(0xFF17203A),
                                        isDismissible: true,
                                        enableDrag: true,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                            child: ListView(
                                              shrinkWrap: true,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              children: [
                                                const Text(
                                                  "Downloads",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                downloadData.isNotEmpty
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const ClampingScrollPhysics(),
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10,
                                                                horizontal: 5),
                                                        itemCount:
                                                            downloadData.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          var key = downloadData
                                                              .keys
                                                              .toList()[index];
                                                          return ListView(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const ClampingScrollPhysics(),
                                                            children: [
                                                              isReady
                                                                  ? AspectRatio(
                                                                      aspectRatio:
                                                                          16 /
                                                                              9,
                                                                      child: MeeduVideoPlayer(
                                                                          controller: _meeduPlayerController
                                                                            ..setFullScreen(true,
                                                                                context)),
                                                                    )
                                                                  : const Center(),
                                                              Text(
                                                                key,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              ListView.builder(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10),
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    const ClampingScrollPhysics(),
                                                                itemCount:
                                                                    downloadData[
                                                                            key]!
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            30,
                                                                        vertical:
                                                                            15),
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                            color: Colors
                                                                                .black26,
                                                                            offset: Offset(0,
                                                                                2),
                                                                            blurRadius:
                                                                                6)
                                                                      ],
                                                                    ),
                                                                    child: GestureDetector(
                                                                        onTap: () {
                                                                          _meeduPlayerController =
                                                                              MeeduPlayerController(
                                                                            enabledButtons:
                                                                                const EnabledButtons(
                                                                              videoFit: false,
                                                                              playBackSpeed: false,
                                                                              pip: true,
                                                                              rewindAndfastForward: true,
                                                                            ),
                                                                            customIcons: const CustomIcons(
                                                                                minimize: Icon(
                                                                                  Icons.fullscreen_exit,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                fullscreen: Icon(Icons.fullscreen_rounded, color: Colors.white),
                                                                                sound: Icon(Icons.volume_up_outlined, color: Colors.white),
                                                                                mute: Icon(Icons.volume_off_outlined, color: Colors.white)),
                                                                          );

                                                                          _meeduPlayerController.header =
                                                                              AppBar(
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            elevation:
                                                                                0,
                                                                            automaticallyImplyLeading:
                                                                                false,
                                                                            leading:
                                                                                IconButton(
                                                                              onPressed: () {
                                                                                print("invoked");
                                                                                isReady = false;
                                                                                Navigator.pop(context);
                                                                                // _meeduPlayerController.setFullScreen(false, context);
                                                                                _meeduPlayerController.dispose();
                                                                                setState(() {});
                                                                                // context.navigator.pop();
                                                                              },
                                                                              icon: const Icon(Icons.arrow_back),
                                                                            ),
                                                                            title:
                                                                                Text(key),
                                                                          );
                                                                          _meeduPlayerController.setFullScreen(
                                                                              true,
                                                                              context);
                                                                          _meeduPlayerController.setDataSource(DataSource(
                                                                              type: DataSourceType.file,
                                                                              file: downloadData[key]![index]));
                                                                        },
                                                                        child: Text(
                                                                          downloadData[key]![index]
                                                                              .path
                                                                              .split("/")
                                                                              .last
                                                                              .split('.')[0],
                                                                          style:
                                                                              const TextStyle(color: Colors.white),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        )),
                                                                  );
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : const Center(),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
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
                                  tooltip: "Random anime",
                                  onPressed: () async {
                                    Toast.show(
                                        "Fecthing random anime for you!!",
                                        duration: 1,
                                        backgroundRadius: 12,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue));
                                    AnimeModel _item =
                                        await AniList.randomAnime();
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              detailPage(_item),
                                        ));
                                  },
                                  icon: const Icon(Icons.auto_awesome_sharp),
                                  splashRadius: 25),
                            )
                          ]),
                    ),
                    listItems()
                  ])
            : listItems());
  }
}
