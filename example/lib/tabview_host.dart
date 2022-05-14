import 'package:flutter/material.dart';

import 'tabviewHostChat.dart';

class TabviewHost extends StatefulWidget {
  const TabviewHost({Key? key}) : super(key: key);

  @override
  State<TabviewHost> createState() => _TabviewHostState();
}

class _TabviewHostState extends State<TabviewHost> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 6,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Host"),
            ),
            body: Column(
              children: [
                const TabBar(tabs: [
                  Tab(
                    icon: Icon(
                      Icons.cloud_outlined,
                      color: Colors.black,
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp, color: Colors.black),
                  ),
                ]),
                Expanded(
                    child: TabBarView(children: [
                  Container(),
                  const TabviewHostChat(),
                  const TabviewHostChat(),
                  const TabviewHostChat(),
                  const TabviewHostChat(),
                  const TabviewHostChat(),
                ]))
              ],
            )));
  }
}
