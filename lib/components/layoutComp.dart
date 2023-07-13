import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:senpai/components/laterPage.dart';
import 'package:senpai/components/recentPage.dart';
import 'package:senpai/components/schedulePage.dart';
import 'package:senpai/components/searchPage.dart';
import 'package:senpai/components/trendingPage.dart';
import 'package:senpai/settings.dart';
import 'package:toast/toast.dart';

class LayoutComp extends StatefulWidget {
  const LayoutComp({super.key});

  @override
  State<LayoutComp> createState() => LayoutCompState();
}

class LayoutCompState extends State<LayoutComp> {
  FocusNode _focus = FocusNode();

  ScrollController scrollController = ScrollController();

  int index = 1;
  // File file = File("'../../assets/images/profilePic.jpg'");
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    List<Widget> pages = [
      trendingPage(scrollController: scrollController),
      Later(scrollController: scrollController),
      search(scrollController: scrollController),
      RecentEpisodes(scrollController: scrollController),
      Schedule(scrollController: scrollController),
    ];
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: MediaQuery.of(context).size.width > 600
            ? ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height),
                    child: IntrinsicHeight(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
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
                            trailing: IconButton(
                                icon: const Icon(Icons.close),
                                focusColor: Colors.redAccent,
                                hoverColor: Colors.redAccent,
                                tooltip: "Close?",
                                splashRadius: 20,
                                onPressed: () {
                                  SystemNavigator.pop();
                                  exit(0);
                                }),
                            onDestinationSelected: (value) {
                              setState(() {
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
                    ),
                  ),
                  pages[index]
                ],
              )
            : Container(
                width: screen.width,
                height: screen.height,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: pages[index]),
        backgroundColor: const Color(0xFF17203A),
        bottomNavigationBar: MediaQuery.of(context).size.width <= 600
            ? BottomNavigationBar(
                mouseCursor: SystemMouseCursors.click,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 15,
                selectedIconTheme:
                    const IconThemeData(color: Colors.greenAccent),
                selectedItemColor: Colors.greenAccent,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFF17203A),
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(MdiIcons.trendingUp), label: "Trends"),
                  BottomNavigationBarItem(
                      activeIcon: Icon(MdiIcons.bookmarkBox),
                      icon: Icon(MdiIcons.bookmarkBoxOutline),
                      label: "Later"),
                  BottomNavigationBarItem(
                      icon: Icon(MdiIcons.magnify), label: "Search"),
                  BottomNavigationBarItem(
                      icon: Icon(MdiIcons.divingScuba), label: "Latest"),
                  BottomNavigationBarItem(
                      icon: Icon(MdiIcons.calendarClockOutline), label: "Next"),
                ],
                currentIndex: index,
                onTap: (value) {
                  index = value;
                  if (scrollController.hasClients) {
                    scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn);
                  }

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
    // TODO: implement dispose
    super.dispose();
  }
}
