import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'list_skeleton.dart';
import 'position.dart';

const constKeepPositionOffset = 40.0;

class ChatList extends StatefulWidget {
  const ChatList({
    Key? key,
    this.messageCount = 0,
    required this.onMessageKey,
    required this.itemBuilder,
    this.latestReadMessageKey,
    this.showLastReadMessageButton = true,
    this.lastReadMessageButtonPosition = const Position(right: 10, bottom: 20),
    this.lastReadMessageButtonBuilder,
    this.lastReadMessageTipBuilder,
    this.loadMoreMessagesWhileMissLatestMsg,
    this.hasMoreNextMessages = false,
    this.hasMorePrevMessages = false,
    this.loadNextMessageOffset,
    this.loadPrevMessageOffset,
    this.loadNextMessages,
    this.loadPrevMessages,
    this.loadNextWidgetBuilder,
    this.loadPrevWidgetBuilder,
    this.showNewMessageComingButton = true,
    this.newMessageComingButtonBuilder,
  }) : super(key: key);

  /// [messageCount] is message source
  /// [onMessageKey] will return the message id
  /// [itemBuilder] is build message widget
  final int messageCount;
  final String Function(int index) onMessageKey;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// [latestReadMessageKey] is the messages last readed
  /// null will be all message is readed
  /// If the latestReadMessage is in [messages], It mean it should be in current view
  /// else it will be not in list.
  /// Does the widget show last message tip. Click it will jump to last message
  /// But if the last messages is not in current source.
  /// [lastReadMessageButtonBuilder] is used to build the button should "Scroll to latest read message"
  /// [lastReadMessageTipBuilder] is used to build the tip like "-------------latest read-------------"
  /// [loadMoreMessagesWhileMissLatestMsg] if latestReadMessageKey in [messages]. just jump to to message.
  /// If it is not in [messages], [loadMoreMessagesWhileMissLatestMsg] will invoke to load. After load, it will also jump to the latest message
  final String? latestReadMessageKey;
  final bool showLastReadMessageButton;
  final Position lastReadMessageButtonPosition;
  final Widget Function()? lastReadMessageButtonBuilder;
  final Widget Function()? lastReadMessageTipBuilder;
  final Future Function()? loadMoreMessagesWhileMissLatestMsg;

  /// Loadmore in end and loadmore in header
  /// [hasMoreNextMessages] is used to tell widget there are more messages need load in scroll to end
  /// [hasMorePrevMessages] is used to tell widget there are more messages need load when scroll to first item
  /// [loadNextMessageOffset] is used to tell widget when scroll offset is reach to end by loadNextMessageOffset,
  /// [loadNextMessages] function will invoke, null or 0 will not enable automatically invoke load function
  /// [loadPrevMessageOffset] is used to tell widget when scroll offset is reach to first item by loadPrevMessageOffset,
  /// [loadPrevMessages] function will invoke, null or 0 will not enable automatically invoke load function
  final bool hasMoreNextMessages;
  final bool hasMorePrevMessages;
  final double? loadNextMessageOffset;
  final double? loadPrevMessageOffset;
  final void Function()? loadNextMessages;
  final void Function()? loadPrevMessages;
  final Widget Function(BuildContext context, LoadStatus? status)?
      loadNextWidgetBuilder;
  final Widget Function(BuildContext context, RefreshStatus? status)?
      loadPrevWidgetBuilder;

  /// The scroll is not in top while user read messages, in this time, new message coming, Does it need should new message coming button
  final bool showNewMessageComingButton;
  final Widget Function(int newCount)? newMessageComingButtonBuilder;

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final listViewController = FlutterListViewController();
  final refreshController = RefreshController(initialRefresh: false);

  int initIndex = 0;

  // Fire refresh temp variable
  double prevScrollOffset = 0;
  // keepPositionOffset will be set to 0 during refresh
  double keepPositionOffset = constKeepPositionOffset;

  @override
  void initState() {
    listViewController.addListener(() {
      var offset = listViewController.offset;

      final torrentDistance = widget.loadPrevMessageOffset ?? 0.0;
      if (widget.hasMorePrevMessages && torrentDistance > 0.0) {
        if (offset <= torrentDistance && prevScrollOffset > torrentDistance) {
          if (!refreshController.isRefresh) {
            refreshController.requestRefresh();
          }
        }
      }

      prevScrollOffset = offset;
    });

    super.initState();
  }

  void _onRefresh() async {
    keepPositionOffset = 0;
    refreshController.refreshCompleted();
    if (mounted) {
      setState(() {});

      Future.delayed(const Duration(milliseconds: 50), (() {
        if (mounted) {
          keepPositionOffset = constKeepPositionOffset;
          setState(() {});
        }
      }));
    }
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) setState(() {});
    refreshController.loadComplete();
  }

  _renderLoadWidget(BuildContext context, LoadStatus? mode) {
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

  _renderRefreshWidget(BuildContext context, RefreshStatus? mode) {
    Widget body;
    if (mode == RefreshStatus.idle) {
      body = const Text("Pull up load prev msg");
    } else if (mode == RefreshStatus.refreshing) {
      body = const ListSkeleton(line: 2);
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

  _renderList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: SmartRefresher(
          enablePullDown: widget.hasMorePrevMessages,
          enablePullUp: widget.hasMoreNextMessages,
          header: CustomHeader(
            completeDuration: const Duration(milliseconds: 0),
            builder: (context, mode) => widget.loadPrevWidgetBuilder != null
                ? widget.loadPrevWidgetBuilder!(context, mode)
                : _renderRefreshWidget(context, mode),
          ),
          footer: CustomFooter(
            builder: (context, mode) => widget.loadNextWidgetBuilder != null
                ? widget.loadNextWidgetBuilder!(context, mode)
                : _renderLoadWidget(context, mode),
          ),
          controller: refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: FlutterListView(
              reverse: true,
              controller: listViewController,
              delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) =>
                      widget.itemBuilder(context, index),
                  childCount: widget.messageCount,
                  onItemKey: (index) => widget.onMessageKey(index),
                  keepPosition: true,
                  keepPositionOffset: 60,
                  initIndex: initIndex,
                  initOffset: 0,
                  initOffsetBasedOnBottom: true,
                  firstItemAlign: FirstItemAlign.end))),
    );
  }

  Widget _renderLastReadButton() {
    return Container(
      child: TextButton(
        onPressed: (() {}),
        child: Text("Jump to latest messages"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: 0, left: 0, right: 0, bottom: 0, child: _renderList()),
      Positioned(
          top: widget.lastReadMessageButtonPosition.top,
          left: widget.lastReadMessageButtonPosition.left,
          right: widget.lastReadMessageButtonPosition.right,
          bottom: widget.lastReadMessageButtonPosition.bottom,
          child: _renderLastReadButton())
    ]);
  }

  @override
  void dispose() {
    listViewController.dispose();
    refreshController.dispose();
    super.dispose();
  }
}
