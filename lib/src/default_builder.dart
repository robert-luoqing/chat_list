import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat_list.dart';

Widget _floatContainer(String text) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: Text(
          text,
          style: TextStyle(color: Colors.green[900]),
        ),
      ),
    ),
  );
}

Widget defaultUnreadMsgButtonBuilder(BuildContext context, int unreadMsgCount) {
  return _floatContainer("$unreadMsgCount new messages");
}

Widget defaultReceivedMsgButtonBuilder(BuildContext context, int newMsgCount) {
  return _floatContainer("Received $newMsgCount messages");
}

Widget defaultScrollToTopButtonBuilder(BuildContext context) {
  return _floatContainer("Scroll to top");
}

Widget defaultLoadMoreProgressBuilder(BuildContext context, LoadStatus? mode) {
  Widget body;
  if (mode == LoadStatus.idle) {
    body = const Text("Pull down to load more message");
  } else if (mode == LoadStatus.loading) {
    body = const CupertinoActivityIndicator();
  } else if (mode == LoadStatus.failed) {
    body = const Text("Load Failed!Click retry!");
  } else if (mode == LoadStatus.canLoading) {
    body = const Text("Release to load more");
  } else {
    body = const Text("No more Data");
  }
  return SizedBox(
    height: 55.0,
    child: Center(child: body),
  );
}

Widget defaultLoadPrevProgressBuilder(
    BuildContext context, RefreshStatus? mode) {
  Widget body;
  if (mode == RefreshStatus.idle) {
    body = const Text("Pull up load prev msg");
  } else if (mode == RefreshStatus.refreshing) {
    body = const CupertinoActivityIndicator();
    // body = const ListSkeleton(line: 2);
  } else if (mode == RefreshStatus.failed) {
    body = const Text("Load Failed!Click retry!");
  } else if (mode == RefreshStatus.canRefresh) {
    body = const Text("Release to load more");
  } else {
    body = const Text("No more Data");
  }
  if (mode == RefreshStatus.completed) {
    return Container();
  } else {
    return RotatedBox(
      quarterTurns: 2,
      child: SizedBox(
        height: 55.0,
        child: Center(child: body),
      ),
    );
  }
}

Widget defaultUnreadMsgTipBuilder(BuildContext context, int unreadMsgCount) {
  return const Center(child: Text("---------Latest read--------"));
}
