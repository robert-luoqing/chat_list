import 'package:chat_list_example/tabview_host.dart';

import 'home.dart';
import 'package:flutter/widgets.dart';

import 'simple_chat_list.dart';
import 'test_chat_list.dart';

class SectionViewRoute {
  static const String initialRoute = "/";
  static final Map<String, WidgetBuilder> routes = {
    "/": (context) => Stack(
          children: const [
            HomePage(
              title: "Home",
            ),
          ],
        ),
    "/testChatList": (context) => const TestChatList(),
    "/simpleChatList": (context) => const SimpleChatList(),
    "/tabviewHost":(context) => const TabviewHost()
  };
}
