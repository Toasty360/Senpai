import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/components/MediaPlayer.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';
import 'package:permission_handler/permission_handler.dart';

class Later extends StatefulWidget {
  final ScrollController scrollController;

  const Later({super.key, required this.scrollController});

  @override
  State<Later> createState() => _LaterState();
}

class _LaterState extends State<Later> {
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
      if (downloads[e.path.split("/").last]!.isEmpty) {
        e.delete().then((value) => print("deleted ig"));
        downloads.remove(e.path.split("/").last);
      }
    }
    // print(downloads);

    setState(() {
      downloadData = downloads;
    });
  }

  getPermissions() async {
    final status = await Permission.storage.status;
    const statusManageStorage = Permission.manageExternalStorage;
    if (status.isDenied ||
        !status.isGranted ||
        !await statusManageStorage.isGranted) {
      await [
        Permission.storage,
        Permission.mediaLibrary,
        Permission.requestInstallPackages,
        Permission.manageExternalStorage,
      ].request();
    }
  }

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  Widget listItems() {
    return ValueListenableBuilder(
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
            scrollController: widget.scrollController,
            settings.enableHentai ? hentaiData : normalData,
            "geners");
      },
    );
  }

  _bottomsheet(Size screen) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: const Color(0xFF17203A),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              const Text(
                "Downloads",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              downloadData.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      itemCount: downloadData.length,
                      itemBuilder: (context, index) {
                        var key = downloadData.keys.toList()[index];
                        return ListView(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: [
                            SizedBox(
                              width: screen.width * 0.8,
                              child: Text(
                                key,
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: downloadData[key]!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: GestureDetector(
                                      onTap: () {
                                        if (currentDownloads.downloads
                                                .containsKey(key) &&
                                            !currentDownloads.downloads[key]!) {
                                          Toast.show("Video not yet downloaded",
                                              duration: Toast.lengthShort);
                                          return;
                                        }
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MediaPlayer(
                                                isM3u8: false,
                                                videoFile:
                                                    downloadData[key]![index],
                                              ),
                                            ));
                                      },
                                      child: SizedBox(
                                        width: screen.width * 0.8,
                                        child: Text(
                                          downloadData[key]![index]
                                              .path
                                              .split("/")
                                              .last
                                              .split('.')[0],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: currentDownloads.downloads
                                                      .containsKey(key)
                                                  ? (currentDownloads
                                                          .downloads[key]!
                                                      ? Colors.white
                                                      : Colors.deepPurple)
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Container(
      child: screen.width <= 600
          ? ListView(
              controller: widget.scrollController,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 30),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                  onTap: () {
                                    print(currentDownloads.downloads);
                                    fetchAllDownloads();
                                    _bottomsheet(screen);
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
                                  Toast.show("Fecthing random anime for you!!",
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
                                        builder: (context) => detailPage(_item),
                                      ));
                                },
                                icon: const Icon(Icons.auto_awesome_outlined,
                                    size: 22),
                                splashRadius: 25),
                          )
                        ]),
                  ),
                  listItems()
                ])
          : listItems(),
    );
  }
}
