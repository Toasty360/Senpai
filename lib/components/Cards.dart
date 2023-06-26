import 'dart:math';

import 'package:flutter/material.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:shimmer/shimmer.dart';

class Cards extends StatelessWidget {
  final List<AnimeModel> data;
  final String subtext;
  Cards(this.data, this.subtext, {super.key});

  Widget MobileCards(ctx, index, screen) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(ctx,
              MaterialPageRoute(builder: (ctx) => detailPage(data[index])));
        },
        child: Container(
          height: 200,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              color: const Color(0xFF17203A),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, offset: Offset(0, 2), blurRadius: 6)
              ],
              image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.09,
                colorFilter: const ColorFilter.srgbToLinearGamma(),
                scale: 1.5,
                image: NetworkImage(data[index].cover),
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
          child: Row(
            children: [
              SizedBox(
                width: screen.width * 0.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    data[index].image,
                    fit: BoxFit.cover,
                    height: 400,
                    errorBuilder: (ctx, error, stackTrace) {
                      return Container(
                          color: Colors.amber,
                          alignment: Alignment.center,
                          child: const Text(
                            'Whoops!',
                            style: TextStyle(fontSize: 30),
                          ));
                    },
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // decoration: BoxDecoration(border: Border.all(width: 10, color: Colors.black)),
                    padding: const EdgeInsets.only(left: 10),
                    width: 200,
                    child: Text(
                      data[index].is_hentai
                          ? data[index].titles
                          : data[index].title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 15),
                    child: Text(
                      subtext == "geners"
                          ? data[index].geners.replaceAll(RegExp(r'[\[\]]'), "")
                          : data[index].episodeNumber,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget desktopCards(ctx, index, screen) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(ctx,
              MaterialPageRoute(builder: (ctx) => detailPage(data[index])));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              shape: BoxShape.rectangle,
              color: const Color(0xFF17203A),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, offset: Offset(0, 2), blurRadius: 6)
              ]),
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  data[index].image,
                  width: 150,
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                        color: Colors.amber,
                        alignment: Alignment.center,
                        child: const Text(
                          'Whoops!',
                          style: TextStyle(fontSize: 30),
                        ));
                  },
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // padding: const EdgeInsets.only(left: 10),
                    width: 200,
                    child: Text(
                      data[index].title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    width: 200,
                    child: Text(
                      data[index].geners,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  final Future<bool> _future = Future<bool>.delayed(
    const Duration(milliseconds: 10),
    () {
      return false;
    },
  );

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 300).toInt();
    final screen = MediaQuery.of(context).size;
    const minCount = 4;
    return Container(
        child: screen.width <= 600
            ? data.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MobileCards(context, index, screen);
                    },
                  )
                : FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const Center(
                          child: Text("No data!"),
                        );
                      }
                      return Shimmer.fromColors(
                          baseColor: const Color(0xFF17203A),
                          highlightColor:
                              const Color.fromARGB(255, 58, 72, 115),
                          enabled: true,
                          child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(8),
                                      height: 200,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          shape: BoxShape.rectangle,
                                          color: const Color(0xFF17203A),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 2),
                                                blurRadius: 6)
                                          ]));
                                },
                              )));
                    })
            : data.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: max(widthCount, minCount),
                          mainAxisExtent: 400,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return desktopCards(context, index, screen);
                      },
                    ),
                  )
                : Shimmer.fromColors(
                    baseColor: const Color(0xFF17203A),
                    highlightColor: const Color.fromARGB(255, 58, 72, 115),
                    enabled: true,
                    child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: max(widthCount, minCount),
                                    mainAxisExtent: 350,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xFF17203A),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 6)
                                    ]),
                              );
                            },
                          ),
                        ))));
  }
}
