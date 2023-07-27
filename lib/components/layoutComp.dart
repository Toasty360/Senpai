import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:senpai/components/laterPage.dart';
import 'package:senpai/components/recentPage.dart';
import 'package:senpai/components/schedulePage.dart';
import 'package:senpai/components/searchPage.dart';
import 'package:senpai/components/trendingPage.dart';
import 'package:senpai/settings.dart';
import 'package:shake/shake.dart';
import 'package:toast/toast.dart';

class LayoutComp extends StatefulWidget {
  final List preFetch;
  const LayoutComp({super.key, required this.preFetch});

  @override
  State<LayoutComp> createState() => LayoutCompState();
}

class LayoutCompState extends State<LayoutComp> {
  ScrollController scrollController = ScrollController();
  final PageController _pageController = PageController(initialPage: 1);

  int index = 1;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
        print("shaked");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RandomSplash()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    List<Widget> pages = [
      trendingPage(
          scrollController: scrollController, topair: widget.preFetch[0]),
      Later(scrollController: scrollController),
      search(scrollController: scrollController),
      RecentEpisodes(
          scrollController: scrollController, data: widget.preFetch[1]),
      Schedule(
          scrollController: scrollController, schedule: widget.preFetch[2]),
    ];
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: MediaQuery.of(context).size.width > 600
            ? Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: NavigationRail(
                        selectedLabelTextStyle:
                            const TextStyle(color: Colors.greenAccent),
                        backgroundColor: const Color(0xFF17203A),
                        elevation: 20,
                        selectedIconTheme:
                            const IconThemeData(color: Colors.greenAccent),
                        leading: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onDoubleTap: () {
                              settings.toggleHentai();
                              setState(() {});
                              Toast.show(
                                  settings.enableHentai
                                      ? "Pheww Hentai enabled"
                                      : "Dang! Hentai disabled",
                                  duration: Toast.lengthShort);
                            },
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                settings.enableHentai
                                    ? "assets/images/female.jpg"
                                    : "assets/images/profilePic.jpg",
                              ),
                              minRadius: 30,
                            )),
                        trailing: screen.height > 400
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                focusColor: Colors.redAccent,
                                hoverColor: Colors.redAccent,
                                tooltip: "Close?",
                                splashRadius: 20,
                                onPressed: () {
                                  SystemNavigator.pop();
                                  exit(0);
                                })
                            : null,
                        onDestinationSelected: (value) {
                          setState(() {
                            // _pageController.jumpToPage(value);
                            index = value;
                          });
                        },
                        labelType: NavigationRailLabelType.selected,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.trending_up),
                            selectedIcon: Icon(Icons.trending_up),
                            label: Text('Trends'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.bookmark_border),
                            selectedIcon: Icon(Icons.book),
                            label: Text('Later'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search_rounded),
                            selectedIcon: Icon(Icons.search_rounded),
                            label: Text('Search'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.all_inclusive_sharp),
                            selectedIcon: Icon(Icons.all_inclusive_sharp),
                            label: Text('Recent'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(
                              Icons.schedule,
                              semanticLabel: "Schedule",
                            ),
                            selectedIcon: Icon(Icons.schedule),
                            label: Text('Schedule'),
                          ),
                        ],
                        selectedIndex: index),
                  ),
                  Expanded(
                    child: Container(
                      child: pages[index],
                    ),
                  )
                ],
              )
            : Container(
                width: screen.width,
                height: screen.height,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    index = value;
                    setState(() {});
                  },
                  children: pages,
                )),
        backgroundColor: const Color(0xFF17203A),
        bottomNavigationBar: MediaQuery.of(context).size.width <= 600
            ? BottomNavyBar(
                curve: Curves.linear,
                showElevation: true,
                backgroundColor: const Color(0xFF17203A),
                items: <BottomNavyBarItem>[
                  BottomNavyBarItem(
                      activeColor: Colors.blueAccent,
                      icon: Icon(MdiIcons.trendingUp),
                      title: const Text("Trends")),
                  BottomNavyBarItem(
                      activeColor: Colors.blueAccent,
                      icon: Icon(MdiIcons.bookmarkBoxOutline),
                      title: const Text("Later")),
                  BottomNavyBarItem(
                      activeColor: Colors.blueAccent,
                      icon: Icon(MdiIcons.magnify),
                      title: const Text("Search")),
                  BottomNavyBarItem(
                      activeColor: Colors.blueAccent,
                      icon: Icon(MdiIcons.divingScuba),
                      title: const Text("Latest")),
                  BottomNavyBarItem(
                      activeColor: Colors.blueAccent,
                      icon: Icon(MdiIcons.calendarClockOutline),
                      title: const Text("Next")),
                ],
                selectedIndex: index,
                onItemSelected: (value) {
                  if (scrollController.hasClients && index == value) {
                    scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);
                  }
                  index = value;
                  _pageController.jumpToPage(value);

                  setState(() {});
                },
              )
            : null);
  }

  List navbaricons = [
    {"name": "Trends", "icon": Icons.trending_up},
    {"name": "Later", "icon": Icons.bookmark},
    {"name": "Search", "icon": Icons.search},
    {"name": "Latest", "icon": Icons.all_inclusive_outlined},
    {"name": "Next", "icon": Icons.schedule},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
