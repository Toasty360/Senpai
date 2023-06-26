import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:senpai/components/layoutComp.dart';

import 'data/anime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "senpei",
    theme: ThemeData(
        fontFamily: 'Open_Sans',
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
    home: const LayoutComp(),
  ));
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 720);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Toasty";
    win.show();
  });
}
