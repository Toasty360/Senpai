// import 'dart:convert';
// import 'dart:io';

// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:senpai/data/anime.dart';

// class AnimeDataController extends GetxController {
//   List<AnimeModel> _savedList = [];

//   List<AnimeModel> get x => _savedList;

//   AnimeDataController() {
//     getInitialData();
//   }

//   //loads the data from the local file
//   //it happens only once
//   void getInitialData() async {
//     _savedList = await readLocalWatchList();
//   }

//   void setData(List<AnimeModel> newList) {
//     _savedList = newList;
//     // writeWatchlistToFile();
//     update();
//   }

//   void removeAt(int i) {
//     _savedList.removeAt(i);
//     // writeWatchlistToFile();
//     update();
//   }

//   void addItemToList(AnimeModel item) {
//     _savedList.add(item);
//     _savedList = _savedList.toSet().toList();
//     // writeWatchlistToFile();
//     update();
//   }

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();

//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/watchlist.txt');
//   }

//   Future<List<AnimeModel>> readLocalWatchList() async {
//     final file = await _localFile;
//     final contents = await file.readAsString();
//     List list = jsonDecode(contents);
//     list = list.map((e) => AnimeModel.toTopAir(e)).toList();
//     // print(_list);
//     return list as List<AnimeModel>;
//   }

//   Future<File> writeWatchlistToFile() async {
//     print("data length will return in file ${_savedList.length}");
//     String jsonData =
//         jsonEncode(_savedList.map((e) => AnimeModel.toJson(e)).toList());

//     final file = await _localFile;
//     return file.writeAsString(jsonData);
//   }
// }
