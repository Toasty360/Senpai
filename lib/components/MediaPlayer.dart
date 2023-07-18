import 'dart:io';
import '../services/anilistFetcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Settings.dart';

class MediaPlayer extends StatefulWidget {
  final File? videoFile;
  final bool isM3u8;
  final String? m3u8Url;
  final String? id;
  final bool? isHentai;

  const MediaPlayer(
      {super.key,
      this.videoFile,
      required this.isM3u8,
      this.m3u8Url,
      this.id,
      this.isHentai});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  final MeeduPlayerController _controller = MeeduPlayerController(
    screenManager: const ScreenManager(
      hideSystemOverlay: true,
      forceLandScapeInFullscreen: true,
      systemUiMode: SystemUiMode.immersiveSticky,
      orientations: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    ),
    loadingWidget: const CircularProgressIndicator(),
    enabledButtons: const EnabledButtons(
        videoFit: false,
        playBackSpeed: false,
        pip: true,
        rewindAndfastForward: true,
        fullscreen: false),
    customIcons: const CustomIcons(
        minimize: Icon(
          Icons.fullscreen_exit,
          color: Colors.white,
        ),
        fullscreen: Icon(Icons.fullscreen_rounded, color: Colors.white),
        sound: Icon(Icons.volume_up_outlined, color: Colors.white),
        mute: Icon(Icons.volume_off_outlined, color: Colors.white)),
    manageWakeLock: true,
    showLogs: false,
    enabledControls: const EnabledControls(
        brightnessSwipes: true,
        doubleTapToSeek: true,
        volumeSwipes: true,
        escapeKeyCloseFullScreen: true,
        desktopDoubleTapToFullScreen: true,
        enterKeyOpensFullScreen: true,
        seekSwipes: true),
    excludeFocus: true,
    autoHideControls: true,
  );
  String currentQuality = "";
  Map quality = {};

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    if (widget.isM3u8) {
      if (widget.isHentai!) {
        _controller.setDataSource(
            DataSource(type: DataSourceType.network, source: widget.m3u8Url!));
      } else {
        readym3u8();
      }
    } else {
      _controller.setDataSource(
          DataSource(type: DataSourceType.file, file: widget.videoFile!));
      _controller.bottomRight = InkWell(
        child: IconButton(
            onPressed: () {
              Duration temp = _controller.sliderPosition.value;
              _controller
                  .seekTo(temp + const Duration(minutes: 1, seconds: 25));
            },
            tooltip: "Skip Openning",
            icon: Icon(MdiIcons.fastForwardOutline)),
      );
    }
    super.initState();
  }

  readym3u8() {
    AniList.fetchSteamingLinks(widget.id!).then((response) {
      for (Map e in response) {
        quality[e["quality"]] = e["url"];
      }
      _controller.bottomRight = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF17203A),
                showDragHandle: true,
                isDismissible: true,
                builder: (ctx) {
                  return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: GridView.builder(
                        cacheExtent: 20,
                        padding: null,
                        shrinkWrap: true,
                        itemCount: quality.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: quality.length),
                        itemBuilder: (context, index) {
                          String _current = quality.keys.toList()[index];
                          return Container(
                            alignment: Alignment.center,
                            child: InkWell(
                                onTap: () {
                                  currentQuality = quality[_current];
                                  var duration =
                                      _controller.sliderPosition.value;
                                  settings.qualityChoice = _current;
                                  ctx.navigator.pop();
                                  setState(() {
                                    _controller.setDataSource(
                                      DataSource(
                                        type: DataSourceType.network,
                                        source: currentQuality,
                                      ),
                                      autoplay: true,
                                    );
                                    _controller.seekTo(duration);
                                  });
                                },
                                child: Text(
                                  quality.keys.toList()[index],
                                  style: TextStyle(
                                      color: settings.qualityChoice == _current
                                          ? Colors.blueAccent
                                          : Colors.white),
                                )),
                          );
                        },
                      ));
                },
              );
            },
            child: const Icon(Icons.high_quality),
          ),
          InkWell(
            child: IconButton(
                onPressed: () {
                  Duration temp = _controller.sliderPosition.value;
                  _controller
                      .seekTo(temp + const Duration(minutes: 1, seconds: 25));
                },
                tooltip: "Skip Openning",
                icon: const Icon(
                  Icons.double_arrow_rounded,
                  color: Colors.white,
                )),
          ),
        ],
      );
      _controller.setDataSource(
        DataSource(
          type: DataSourceType.network,
          source: currentQuality != ""
              ? currentQuality
              : quality[settings.qualityChoice] ?? quality["default"],
        ),
        autoplay: true,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MeeduVideoPlayer(controller: _controller));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }
}
