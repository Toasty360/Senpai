import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class Cards extends StatefulWidget {
  final List<AnimeModel> data;
  final String subtext;
  FocusNode? focus;
  final ScrollController scrollController;

  Cards(this.data, this.subtext, {super.key, required this.scrollController});

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  Widget MobileCards(ctx, index, screen) {
    return InkWell(
      radius: 0,
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (ctx) => detailPage(widget.data[index])));
      },
      hoverColor: Colors.amberAccent,
      autofocus: true,
      // focusNode: FocusNode(),
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
              image: NetworkImage(widget.data[index].cover),
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
                  widget.data[index].image,
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
                  padding: const EdgeInsets.only(left: 10),
                  width: 200,
                  child: Text(
                    widget.data[index].is_hentai
                        ? widget.data[index].titles
                        : widget.data[index].title,
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
                    widget.subtext == "geners"
                        ? widget.data[index].geners
                            .replaceAll(RegExp(r'[\[\]]'), "")
                        : widget.data[index].episodeNumber,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget desktopCards(ctx, index, screen) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: InkWell(
        focusColor: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (ctx) => detailPage(widget.data[index])));
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
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.data[index].image,
                  scale: 1,
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
                      widget.data[index].title,
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
                      widget.data[index].geners,
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: screen.width <= 600
            ? widget.data.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: widget.scrollController,
                    addAutomaticKeepAlives: true,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: widget.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MobileCards(context, index, screen);
                    },
                  )
                : const Center(
                    child: Text("No data!"),
                  )
            : widget.data.isNotEmpty
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
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) {
                        return desktopCards(context, index, screen);
                      },
                    ),
                  )
                : const Center(
                    child: Text("No data!"),
                  ));
  }
}
