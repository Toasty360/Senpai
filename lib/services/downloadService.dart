// ignore: file_names
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

// class Download {
//   final String id;
//   final String name;
//   final double progress;
//   final bool downloadStatus;

//   Download(this.id, this.name, this.progress, this.downloadStatus);
// }

// 123: {"id": 1, "name": "name", "progress": 100.0, "downloadStatus": true}

Map<int, dynamic> currentDownloadings = {};

class DownloadService {
  Future<void> convertM3U8toMP4({
    required String m3u8Url,
    required String title,
    required String name,
  }) async {
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

    currentDownloadings[fileName.hashCode] = {
      "id": 1,
      "name": fileName,
      "progress": 0,
      "downloadStatus": false,
    };

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

          currentDownloadings[fileName.hashCode]["progress"] = progress;
          print('Conversion Progress: $progress%');
        }
      }
    });
    await flutterFFmpeg.executeAsync(
      '-i $m3u8Url -bsf:a aac_adtstoasc -vcodec copy -c copy $animePath/${name.replaceAll(RegExp(r'\/[]{}@$#%^&*()'), "").replaceAll(" ", "_")}.mp4',
      (execution) {
        currentDownloadings[fileName.hashCode]["id"] = execution.executionId;
      },
    ).then((value) {
      if (value == 0) {
        // currentDownloads.downloads[fileName] = true;
        Toast.show("Download sucessful!");
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
}
