import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:senpai/components/layoutComp.dart';
import 'services/anilistFetcher.dart';

import 'data/anime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var t = AniList.fetchTopAir();
  var r = AniList.fetchRecent();
  var s = AniList.fetchSchedule();
  initMeeduPlayer();
  await Hive.initFlutter(
    (await Directory(
                '${(await getApplicationDocumentsDirectory()).path}/.toast')
            .create())
        .path,
  );
  Hive.registerAdapter(EpisodeModelAdapter());
  Hive.registerAdapter(AnimeModelAdapter());
  await Hive.openBox('Later');
  await Hive.openBox('WatchedIndexs');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    darkTheme: ThemeData.dark(
      useMaterial3: true,
    ),
    shortcuts: {
      LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
    },
    theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        // fontFamily: 'Open_Sans',
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF17203A))),
    home: LayoutComp(
      preFetch: [t, r, s],
    ),
  ));
  try {
    doWhenWindowReady(() {
      final win = appWindow;
      win.alignment = Alignment.center;
      win.title = "Toasty";
      win.show();
    });
  } catch (e) {
    print(e);
  }
}

//app-release.apk
// flutter build apk --target-platform android-arm --analyze-size
// flutter build apk --target-platform android-arm64 --analyze-size
// flutter build apk --target-platform android-x64 --analyze-size


// flutter build apk --split-per-abi
//generates
// √  Built build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk (31.8MB).
// √  Built build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (33.1MB).
// √  Built build\app\outputs\flutter-apk\app-x86_64-release.apk (39.0MB).
