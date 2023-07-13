import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:senpai/components/Cards.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';
import 'package:senpai/services/hanimeFetcher.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';

class search extends StatefulWidget {
  final ScrollController scrollController;

  const search({super.key, required this.scrollController});

  @override
  State<search> createState() => _searchState();
}

// ignore: camel_case_types
class _searchState extends State<search> {
  static List<AnimeModel> data = [];
  TextEditingController _controller = TextEditingController();
  var page = 1;
  bool goterror = false;
  bool isLoaded = false;
  bool isDataNew = false;
  late String currentSearch = "";
  bool isAdvSearch = false;

  List genres = [
    {
      "value": false,
      "type": "Action",
    },
    {
      "value": false,
      "type": "Adventure",
    },
    {
      "value": false,
      "type": "Cars",
    },
    {
      "value": false,
      "type": "Comedy",
    },
    {
      "value": false,
      "type": "Drama",
    },
    {
      "value": false,
      "type": "Fantasy",
    },
    {
      "value": false,
      "type": "Horror",
    },
    {
      "value": false,
      "type": "Mahou Shoujo",
    },
    {
      "value": false,
      "type": "Mecha",
    },
    {
      "value": false,
      "type": "Mystery",
    },
    {
      "value": false,
      "type": "Psychological",
    },
    {
      "value": false,
      "type": "Romance",
    },
    {
      "value": false,
      "type": "Sci-Fi",
    },
    {
      "value": false,
      "type": "Slice of Life",
    },
    {
      "value": false,
      "type": "Sports",
    },
    {
      "value": false,
      "type": "Supernatural",
    },
    {
      "value": false,
      "type": "Thriller",
    },
  ];

  late List<String> queryString = [];

  getAnime(var value) async {
    print(page);
    await AniList.searchData(value.toString(), page: page).then((res) {
      print(res.length);
      goterror = res.length == 0;
      isLoaded = true;
      data.addAll(res);
      page++;
      setState(() {});
    });
  }

  Widget loader = const Center(
    child: Text("Nothing to see here", style: TextStyle(color: Colors.white)),
  );

  fetchAdvSearch() async {
    await AniList.advancedSearch(queryString, page: page).then((res) {
      data.addAll(res);
      page++;
      isLoaded = true;
      goterror = res.length == 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _screen = MediaQuery.of(context).size;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent &&
            isLoaded) {
          print("enterd");
          isLoaded = false;

          if (isAdvSearch) {
            if (genres.isNotEmpty && AniList.advSearchHasNext) {
              Toast.show("Loading more!");
              fetchAdvSearch();
            }
          } else {
            if (_controller.text.isNotEmpty && AniList.searchHasNext) {
              Toast.show("Loading more!");

              getAnime(currentSearch);
            }
          }
        }
        return true;
      },
      child: Container(
          color: const Color(0xFF17203A),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:
              ListView(controller: widget.scrollController, children: <Widget>[
            !kIsWeb
                ? Container(
                    height: 100,
                    width: _screen.width,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 91, 105, 148),
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: _screen.width * 0.8,
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: _controller,
                            decoration: InputDecoration(
                              suffix: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    backgroundColor: const Color(0xFF17203A),
                                    isDismissible: true,
                                    showDragHandle: true,
                                    useSafeArea: true,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (ctx) {
                                      return Container(
                                        child: ListView(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 10),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                alignment:
                                                    Alignment.centerRight,
                                                height: 50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Geners",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        isAdvSearch = true;
                                                        page = 1;
                                                        data = [];
                                                        goterror = false;

                                                        setState(() {});
                                                        Toast.show(
                                                            "Fetching data!",
                                                            duration: Toast
                                                                .lengthShort);
                                                        ctx.navigator.pop();
                                                        fetchAdvSearch();
                                                        //call data
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .blueAccent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: const Text(
                                                          "Fetch?",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            StatefulBuilder(
                                              builder: (context, setState) {
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount: genres.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return CheckboxListTile(
                                                      value: genres[index]
                                                          ["value"],
                                                      title: Text(genres[index]
                                                          ["type"]),
                                                      onChanged: (value) {
                                                        if (value!) {
                                                          genres[index]
                                                              ["value"] = true;
                                                          queryString.add(
                                                              genres[index]
                                                                  ["type"]);
                                                        } else {
                                                          genres[index]
                                                              ["value"] = false;
                                                          queryString.remove(
                                                              genres[index]
                                                                  ["type"]);
                                                        }
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(MdiIcons.tune),
                              ),
                              prefixIcon: Icon(Icons.search),
                              border: UnderlineInputBorder(),
                              hintText: "Search",
                              fillColor: Colors.white,
                              hintStyle: TextStyle(color: Colors.white),
                            ),
                            onSubmitted: (String value) {
                              isAdvSearch = false;
                              data = [];

                              if (_controller.text != "") {
                                if (currentSearch == _controller.text) {
                                } else {
                                  print("Searching ig");
                                  data = [];
                                  page = 1;
                                  currentSearch = _controller.text;
                                  loader = const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Please wait fetching the anime!",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ]);
                                  setState(() {});
                                  getAnime(currentSearch);
                                  if (settings.enableHentai) {
                                    Future.delayed(
                                        const Duration(milliseconds: 5), () {
                                      HentaiHome(searchfor: currentSearch)
                                          .then((value) {
                                        setState(() {
                                          data.addAll(value);
                                        });
                                      });
                                    });
                                  }
                                }
                              } else {
                                page = 1;
                                data = [];
                                goterror = true;
                                setState(() {});
                              }
                              if (currentSearch == _controller.text) {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ))
                : Center(),
            Container(
              height: 10,
              color: Colors.transparent,
            ),
            data.isEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: goterror
                        ? const Center(
                            child: Text("Nothing to see here",
                                style: TextStyle(color: Colors.white)),
                          )
                        : Center(
                            child: loader,
                          ),
                  )
                : Cards(
                    data,
                    "geners",
                    scrollController: widget.scrollController,
                  ),
          ])),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
