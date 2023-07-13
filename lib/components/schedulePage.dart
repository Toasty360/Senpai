import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senpai/components/detailPage.dart';
import 'package:senpai/data/anime.dart';
import 'package:senpai/services/anilistFetcher.dart';

class Schedule extends StatefulWidget {
  final ScrollController scrollController;
  const Schedule({super.key, required this.scrollController});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  static List<ScheduleModel> data = [];

  bool isLoaded = false;
  int page = 1;
  bool hasNextPage = false;

  fetchSchedule() async {
    await AniList.fetchSchedule(page: page).then((res) {
      if (res.isNotEmpty) {
        if (data.isEmpty) {
          data = res;
        } else {
          data.addAll(res);
        }
      }
      isLoaded = true;
      setState(() {});
    });

    // print(data.length);
    // Future.delayed(Duration(milliseconds: 5), () {
    //   setState(() {});
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (data.isEmpty) {
      fetchSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthCount = (MediaQuery.of(context).size.width ~/ 400).toInt();
    final screen = MediaQuery.of(context).size;
    const minCount = 2;
    return Scaffold(
      backgroundColor: const Color(0xFF17203A),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent &&
              AniList.hasNext &&
              isLoaded) {
            isLoaded = false;
            page++;
            fetchSchedule();
          }
          return true;
        },
        child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: data.isNotEmpty
              ? (screen.width <= 600
                  ? ListView.builder(
                      controller: widget.scrollController,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              var currentItem = data[index].details.aniId;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          detailPage(data[index].details)));
                            },
                            child: Container(
                                margin: const EdgeInsets.all(10),
                                height: 190,
                                width: 200,
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                  color: const Color(0xFF17203A),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 6)
                                  ],
                                  // border: Border.all(width: 1,color: Colors.white),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    opacity: 0.09,
                                    colorFilter:
                                        const ColorFilter.srgbToLinearGamma(),
                                    scale: 1.5,
                                    image:
                                        NetworkImage(data[index].details.cover),
                                    onError: (exception, stackTrace) {
                                      Container(
                                          color: Colors.amber,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Whoops!',
                                            style: TextStyle(fontSize: 10),
                                          ));
                                    },
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          data[index].details.image,
                                          fit: BoxFit.cover,
                                          height: 400,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                                color: Colors.amber,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Whoops!',
                                                  style:
                                                      TextStyle(fontSize: 30),
                                                ));
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: context.width * 0.55,
                                        height: context.height,
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 20),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data[index].details.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Airing at:",
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                width: context.width * 0.4,
                                                // decoration: BoxDecoration(
                                                //     border: Border.all(
                                                //         width: 1,
                                                //         color: Colors.white)),
                                                child: Text(
                                                  getTime(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          data[index].schedule[
                                                                  "airingAt"] *
                                                              1000)),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  maxLines: 2,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Ep: ",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.amber),
                                                      ),
                                                      Text(
                                                          data[index].schedule[
                                                              "episode"],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .green))
                                                    ]),
                                              )
                                            ])),
                                  ],
                                )),
                          ),
                        );
                      },
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: max(widthCount, minCount),
                                  mainAxisExtent: 350,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => detailPage(
                                                  data[index].details)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
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
                                        ],
                                      ),
                                      child: Stack(children: [
                                        Container(
                                          width: double.maxFinite,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                opacity: 0.5,
                                                colorFilter: const ColorFilter
                                                    .srgbToLinearGamma(),
                                                scale: 1.5,
                                                image: NetworkImage(
                                                    data[index].details.cover),
                                                onError:
                                                    (exception, stackTrace) {
                                                  Container(
                                                      color: Colors.amber,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        'Whoops!',
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ));
                                                },
                                              )),
                                        ),
                                        Positioned(
                                          top: screen.height * 0.02,
                                          left: screen.width * 0.01,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                              data[index].details.image,
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: 150,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                    color: Colors.amber,
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      'Whoops!',
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ));
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: screen.width < 800
                                              ? screen.height * 0.27
                                              : screen.height * 0.20,
                                          left: screen.width < 1200
                                              ? screen.width < 800
                                                  ? 0
                                                  : screen.width * 0.18
                                              : screen.width * 0.12,
                                          child: Container(
                                              width: context.width * 0.55,
                                              height: context.height,
                                              padding: const EdgeInsets.only(
                                                  top: 20, left: 20),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data[index].details.title,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      "Airing at:",
                                                      style: TextStyle(
                                                          color: Colors.amber),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          context.width * 0.4,
                                                      // decoration: BoxDecoration(
                                                      //     border: Border.all(
                                                      //         width: 1,
                                                      //         color: Colors.white)),
                                                      child: Text(
                                                        getTime(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                data[index].schedule[
                                                                        "airingAt"] *
                                                                    1000)),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Ep: ",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber),
                                                            ),
                                                            Text(
                                                                data[index]
                                                                        .schedule[
                                                                    "episode"],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .green))
                                                          ]),
                                                    )
                                                  ])),
                                        )
                                      ]),
                                    )));
                          })))
              : const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Please wait fetching the latest schedule!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ])),
        ),
      ),
    );
  }

  getTime(DateTime time) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "July",
      "Aug",
      "Sept",
      "Oct",
      "Nov",
      "Dec"
    ];
    // time=time.toUtc();
    var min = time.minute;
    return "${time.hour > 12 ? "${time.hour - 12}${time.minute == 0 ? "" : ":${time.minute}"} PM" : "${time.hour}${time.minute == 0 ? "" : ":${time.minute}"} AM"} on ${months[time.month - 1]} ${time.day}${time.day == 2 ? "nd" : time.day == 3 ? "rd" : time.day == 4 ? "rth" : "th"}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
