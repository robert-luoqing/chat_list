import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'chat_list_controller.dart';
import 'default_builder.dart';
import 'position.dart';

const constKeepPositionOffset = 40.0;
const constLargeUnreadIndex = 100000000000;

class ChatList extends StatefulWidget {
  const ChatList({
    Key? key,
    this.msgCount = 0,
    required this.onMsgKey,
    required this.itemBuilder,
    this.latestReadMsgKey,
    this.showUnreadMsgButton = true,
    this.unreadMsgCount = 0,
    this.unreadMsgButtonPosition = const Position(right: 0, top: 20),
    this.unreadMsgButtonBuilder,
    this.unreadMsgTipBuilder,
    this.onLoadMsgsByLatestReadMsgKey,
    this.offsetFromUnreadTipToTop = 50,
    this.hasMoreMsgs = false,
    this.hasPrevMsgs = false,
    this.offsetToTriggerLoadMore,
    this.offsetToTriggerLoadPrev,
    this.onLoadMoreMsgs,
    this.onLoadPrevMsgs,
    this.loadMoreProgressBuilder,
    this.loadPrevProgressBuilder,
    this.showReceivedMsgButton = true,
    this.receivedMsgButtonPosition = const Position(right: 0, bottom: 20),
    this.receivedMsgButtonBuilder,
    this.onIsReceiveMessage,
    this.showScrollToTopButton = true,
    this.offsetToShowScrollToTop = 400,
    this.scrollToTopButtonBuilder,
    this.physics,
    this.scrollBehavior,
    this.onLoadTopMsgs,
    this.controller,
  }) : super(key: key);

  /// [msgCount] is message count
  /// [onMsgKey] will return the message id
  /// [itemBuilder] is build message widget
  final int msgCount;
  final String Function(int index) onMsgKey;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// [latestReadMsgKey] is the messages last readed
  /// null will be all message is readed
  /// If the latestReadMessage is in [messages], It mean it should be in current view
  /// else it will be not in list.
  /// Does the widget show last message tip. Click it will jump to last message
  /// But if the last messages is not in current source.
  /// [unreadMsgButtonBuilder] is used to build the button should "Scroll to latest read message"
  /// [unreadMsgTipBuilder] is used to build the tip like "-------------latest read-------------"
  /// [onLoadMsgsByLatestReadMsgKey] if latestReadMessageKey in [messages]. just jump to to message.
  /// If it is not in [messages], [onLoadMsgsByLatestReadMsgKey] will invoke to load. After load, it will also jump to the latest message
  /// When user click scroll to latest unread message. The widget will scroll to the unread item to top by [offsetFromUnreadTipToTop] offset
  final String? latestReadMsgKey;
  final bool showUnreadMsgButton;
  final Position unreadMsgButtonPosition;
  final int unreadMsgCount;
  final Widget Function(BuildContext context, int unreadCount)?
      unreadMsgButtonBuilder;
  final Widget Function(BuildContext context, int unreadCount)?
      unreadMsgTipBuilder;
  final Future Function()? onLoadMsgsByLatestReadMsgKey;
  final double offsetFromUnreadTipToTop;

  /// [hasMoreMsgs] is used to tell widget there are more messages need load in scroll to end
  /// [offsetToTriggerLoadMore] is used to tell widget when scroll offset is reach to end by loadNextMessageOffset,
  /// [onLoadMoreMsgs] function will invoke, null or 0 will not enable automatically invoke load function
  final bool hasMoreMsgs;
  final double? offsetToTriggerLoadMore;
  final Future Function()? onLoadMoreMsgs;
  final Widget Function(BuildContext context, LoadStatus? status)?
      loadMoreProgressBuilder;

  /// Loadmore in end and loadmore in header
  /// [hasPrevMsgs] is used to tell widget there are more messages need load when scroll to first item
  /// [offsetToTriggerLoadPrev] is used to tell widget when scroll offset is reach to first item by loadPrevMessageOffset,
  /// [onLoadPrevMsgs] function will invoke, null or 0 will not enable automatically invoke load function
  final bool hasPrevMsgs;
  final double? offsetToTriggerLoadPrev;
  final Future Function()? onLoadPrevMsgs;
  final Widget Function(BuildContext context, RefreshStatus? status)?
      loadPrevProgressBuilder;

  /// The scroll is not in top while user read messages, in this time, new message coming, Does it need should new message coming button
  /// [onIsReceiveMessage] Does it is received message, not send or tip message
  final bool showReceivedMsgButton;
  final Position receivedMsgButtonPosition;
  final Widget Function(BuildContext context, int newCount)?
      receivedMsgButtonBuilder;
  final bool Function(int index)? onIsReceiveMessage;

  /// [showScrollToTopButton] is true will determine show the scroll to top button
  /// when scroll offset > [offsetToShowScrollToTop], the button will be show up
  final bool showScrollToTopButton;
  final double offsetToShowScrollToTop;
  final Widget Function(BuildContext context)? scrollToTopButtonBuilder;

  /// When jump to top, library will detect whether the [hasPrevMsgs] is true,
  /// If the value is true, invoke [onLoadTopMsgs] to load first screen messages
  final Future Function()? onLoadTopMsgs;

  final ChatListController? controller;

  /// Inherit from scrollview
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;

  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  final listViewController = FlutterListViewController();
  final refreshController = RefreshController(initialRefresh: false);
  List<FlutterListViewItemPosition> itemPositions = [];
  int initIndex = 0;

  /// Fire refresh temp variable
  double prevScrollOffset = 0;
  double nextBottomScrollOffset = 100000000000000.0;

  /// keepPositionOffset will be set to 0 during refresh
  double keepPositionOffset = constKeepPositionOffset;

  /// show move to top
  ValueNotifier<bool> isShowMoveToTop = ValueNotifier<bool>(false);

  /// new message state fields
  ValueNotifier<int> newMessageCount = ValueNotifier<int>(0);
  String? firstNewMessageKey;
  int? firstNewMessageIndex;

  /// last read message state fields
  ValueNotifier<bool> showLastUnreadButton = ValueNotifier<bool>(false);
  String? lastReadMessageKey;
  int? latestUnreadMessageIndex;

  /// New message first key
  /// When reach new message, the count will be disppear
  /// For example if new message [{id: 1},{id:2},{id:3}], the key should be 1
  /// if [hasPrevMsgs] is true, widget can calc the count, we need simple increase [newMsgCount]
  notifyNewMessageComing(String firstKey, int newMsgCount) {
    _handleNewMessageComing(firstKey, newMsgCount);
  }

  _handleLastMessageButton(bool forceToInitToTrue) {
    if (widget.showUnreadMsgButton && lastReadMessageKey != null) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        latestUnreadMessageIndex = constLargeUnreadIndex;
        var newUnreadMessageIndex = _getLatestUnReadMessageIndex();
        if (newUnreadMessageIndex != null) {
          latestUnreadMessageIndex = newUnreadMessageIndex;
        }
        if (forceToInitToTrue) {
          showLastUnreadButton.value = true;
        }

        _determineShowLatestUnreadMsgButton();
      });
    } else {
      lastReadMessageKey = null;
      latestUnreadMessageIndex = null;
      if (showLastUnreadButton.value) {
        showLastUnreadButton.value = false;
      }
    }
  }

  int? _getLatestUnReadMessageIndex() {
    for (var i = 0; i < widget.msgCount; i++) {
      if (widget.onMsgKey(i) == lastReadMessageKey) {
        // 是last message index的前一个
        return i > 0 ? i - 1 : 0;
      }
    }

    return null;
  }

  _determineShowLatestUnreadMsgButton() {
    if (widget.showUnreadMsgButton && itemPositions.isNotEmpty) {
      if (latestUnreadMessageIndex == null ||
          itemPositions.last.index >= latestUnreadMessageIndex!) {
        lastReadMessageKey = null;
        latestUnreadMessageIndex = null;
        if (showLastUnreadButton.value != false) {
          showLastUnreadButton.value = false;
        }
      }
    }
  }

  _handleNewMessageComing(String? firstKey, int? newMsgCountInThisTime) {
    if (widget.showReceivedMsgButton) {
      // Next round to set key
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        if (firstKey != null) {
          firstNewMessageKey ??= firstKey;
        }

        if (firstNewMessageKey != null) {
          int newMsgCount = 0;
          if (widget.hasPrevMsgs) {
            if (newMsgCountInThisTime != null) {
              newMsgCount = newMessageCount.value + newMsgCountInThisTime;
            } else {
              newMsgCount = newMessageCount.value;
            }

            firstNewMessageIndex = -1;
            for (var i = 0; i < widget.msgCount; i++) {
              if (widget.onMsgKey(i) == firstNewMessageKey) {
                firstNewMessageIndex = i;
                break;
              }
            }
          } else {
            firstNewMessageIndex = null;
            for (var i = 0; i < widget.msgCount; i++) {
              if (widget.onIsReceiveMessage == null ||
                  widget.onIsReceiveMessage!(i)) {
                newMsgCount++;

                if (widget.onMsgKey(i) == firstNewMessageKey) {
                  firstNewMessageIndex = i;
                  break;
                }
              }
            }
          }

          newMessageCount.value = newMsgCount;
          _determineShowNewMsgCount();
        }
      });
    } else {
      if (newMessageCount.value != 0) {
        newMessageCount.value = 0;
        firstNewMessageKey = null;
        firstNewMessageIndex = null;
      }
    }
  }

  _determineShowNewMsgCount() {
    if (widget.showReceivedMsgButton && itemPositions.isNotEmpty) {
      if (firstNewMessageIndex == null ||
          itemPositions[0].index <= firstNewMessageIndex!) {
        if (newMessageCount.value != 0) {
          newMessageCount.value = 0;
        }
        firstNewMessageKey = null;
        firstNewMessageIndex = null;
      }
    }
  }

  _handleScrolling() {
    var offset = listViewController.offset;
    ScrollPosition position = listViewController.position;
    var maxScrollExtent = position.maxScrollExtent;

    var loadNextMessageOffset = widget.offsetToTriggerLoadMore ?? 0;
    var targetNextOffset = maxScrollExtent - loadNextMessageOffset;

    if (widget.hasMoreMsgs && loadNextMessageOffset > 0.0) {
      if (offset >= targetNextOffset &&
          nextBottomScrollOffset < targetNextOffset) {
        if (!refreshController.isLoading) {
          refreshController.requestLoading();
        }
      }
    }

    nextBottomScrollOffset = offset;

    /// Handle trigger load prev
    final torrentDistance = widget.offsetToTriggerLoadPrev ?? 0.0;
    if (widget.hasPrevMsgs && torrentDistance > 0.0) {
      if (offset <= torrentDistance && prevScrollOffset > torrentDistance) {
        if (!refreshController.isRefresh) {
          refreshController.requestRefresh();
        }
      }
    }
    prevScrollOffset = offset;

    /// Handle move to top button display or hide
    if (offset > widget.offsetToShowScrollToTop) {
      isShowMoveToTop.value = true;
    } else {
      isShowMoveToTop.value = false;
    }
  }

  @override
  void initState() {
    listViewController.sliverController.onPaintItemPositionsCallback =
        (widgetHeight, positions) {
      itemPositions = positions;
      _determineShowNewMsgCount();
      _determineShowLatestUnreadMsgButton();
    };

    listViewController.addListener(_handleScrolling);

    widget.controller?.mount(this);
    lastReadMessageKey = widget.latestReadMsgKey;
    _handleLastMessageButton(true);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?.mount(this);
    if (firstNewMessageKey != null) {
      _handleNewMessageComing(null, null);
    }
    if (oldWidget.latestReadMsgKey != widget.latestReadMsgKey) {
      lastReadMessageKey = widget.latestReadMsgKey;
      _handleLastMessageButton(true);
    } else {
      _handleLastMessageButton(false);
    }
  }

  Future _onLoading() async {
    try {
      if (widget.onLoadMoreMsgs != null) {
        await widget.onLoadMoreMsgs!();
      }

      refreshController.loadComplete();
    } catch (e, s) {
      debugPrint("load more error in chat list lib: $e, $s");
      refreshController.loadFailed();
    }
  }

  Future _onRefresh() async {
    keepPositionOffset = 0;
    setState(() {});

    try {
      if (widget.onLoadPrevMsgs != null) {
        await widget.onLoadPrevMsgs!();
      }

      refreshController.refreshCompleted();
    } catch (e, s) {
      debugPrint("refresh error in chat list lib: $e, $s");
      refreshController.refreshFailed();
    }

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 50), (() {
        if (mounted) {
          keepPositionOffset = constKeepPositionOffset;
          setState(() {});
        }
      }));
    }
  }

  Future _scrollToTop() async {
    if (widget.hasPrevMsgs) {
      if (widget.onLoadTopMsgs != null) {
        await widget.onLoadTopMsgs!();
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    listViewController.sliverController.animateToIndex(0,
        duration: const Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }

  _scrollToLatestReadMessage() async {
    bool clearData = false;
    if (latestUnreadMessageIndex != null) {
      if (constLargeUnreadIndex != latestUnreadMessageIndex) {
        listViewController.sliverController.animateToIndex(
            latestUnreadMessageIndex!,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceInOut,
            offsetBasedOnBottom: true,
            offset: widget.offsetFromUnreadTipToTop);
        clearData = true;
      } else {
        if (widget.onLoadMsgsByLatestReadMsgKey != null) {
          await widget.onLoadMsgsByLatestReadMsgKey!();
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            var newUnreadMessageIndex = _getLatestUnReadMessageIndex();
            if (constLargeUnreadIndex != newUnreadMessageIndex &&
                newUnreadMessageIndex != null) {
              listViewController.sliverController.animateToIndex(
                  newUnreadMessageIndex,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.bounceInOut,
                  offsetBasedOnBottom: true,
                  offset: widget.offsetFromUnreadTipToTop);
            }

            lastReadMessageKey = null;
            latestUnreadMessageIndex = null;
            if (showLastUnreadButton.value) {
              showLastUnreadButton.value = false;
            }
          });
        } else {
          clearData = true;
        }
      }
    }

    if (clearData) {
      lastReadMessageKey = null;
      latestUnreadMessageIndex = null;
      if (showLastUnreadButton.value) {
        showLastUnreadButton.value = false;
      }
    }
  }

  Widget _renderItem(BuildContext context, int index) {
    if (widget.onMsgKey(index) == widget.latestReadMsgKey) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.itemBuilder(context, index),
          widget.unreadMsgTipBuilder != null
              ? widget.unreadMsgTipBuilder!(context, widget.unreadMsgCount)
              : defaultUnreadMsgTipBuilder(context, index)
        ],
      );
    }
    return widget.itemBuilder(context, index);
  }

  _renderList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: SmartRefresher(
          enablePullDown: widget.hasPrevMsgs,
          enablePullUp: widget.hasMoreMsgs,
          header: CustomHeader(
            completeDuration: const Duration(milliseconds: 0),
            builder: (context, mode) => widget.loadPrevProgressBuilder != null
                ? widget.loadPrevProgressBuilder!(context, mode)
                : defaultLoadPrevProgressBuilder(context, mode),
          ),
          footer: CustomFooter(
            builder: (context, mode) => widget.loadMoreProgressBuilder != null
                ? widget.loadMoreProgressBuilder!(context, mode)
                : defaultLoadMoreProgressBuilder(context, mode),
          ),
          controller: refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: FlutterListView(
              reverse: true,
              controller: listViewController,
              physics: widget.physics,
              scrollBehavior: widget.scrollBehavior,
              delegate: FlutterListViewDelegate(_renderItem,
                  childCount: widget.msgCount,
                  onItemKey: (index) => widget.onMsgKey(index),
                  keepPosition: true,
                  keepPositionOffset: keepPositionOffset,
                  initIndex: initIndex,
                  initOffset: 0,
                  initOffsetBasedOnBottom: true,
                  firstItemAlign: FirstItemAlign.end))),
    );
  }

  Widget _renderLastReadButton() {
    return ValueListenableBuilder(
        valueListenable: showLastUnreadButton,
        builder: (context, bool showButton, child) {
          if (widget.showUnreadMsgButton && showButton) {
            return GestureDetector(
              onTap: _scrollToLatestReadMessage,
              child: widget.unreadMsgButtonBuilder != null
                  ? widget.unreadMsgButtonBuilder!(
                      context, widget.unreadMsgCount)
                  : defaultUnreadMsgButtonBuilder(
                      context, widget.unreadMsgCount),
            );
          }
          return Container();
        });
  }

  Widget _renderNewMessagesButtonOrScrollToTop() {
    return ValueListenableBuilder(
      valueListenable: isShowMoveToTop,
      builder: (context, bool showTop, child) => ValueListenableBuilder(
        valueListenable: newMessageCount,
        builder: (context, int newMsgCount, child) {
          Widget? renderWidget;

          if (newMsgCount > 0) {
            if (widget.showReceivedMsgButton) {
              renderWidget = _renderNewMessagesButton(newMsgCount);
            }
          }

          if (renderWidget == null && showTop) {
            if (widget.showScrollToTopButton) {
              renderWidget = _renderScrollToTop();
            }
          }

          renderWidget ??= Container();
          return renderWidget;
        },
      ),
    );
  }

  Widget _renderNewMessagesButton(int newMsgCount) {
    return GestureDetector(
      onTap: _scrollToTop,
      child: widget.receivedMsgButtonBuilder != null
          ? widget.receivedMsgButtonBuilder!(context, newMsgCount)
          : defaultReceivedMsgButtonBuilder(context, newMsgCount),
    );
  }

  Widget _renderScrollToTop() {
    return GestureDetector(
      onTap: _scrollToTop,
      child: widget.scrollToTopButtonBuilder != null
          ? widget.scrollToTopButtonBuilder!(context)
          : defaultScrollToTopButtonBuilder(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: 0, left: 0, right: 0, bottom: 0, child: _renderList()),
      Positioned(
          top: widget.unreadMsgButtonPosition.top,
          left: widget.unreadMsgButtonPosition.left,
          right: widget.unreadMsgButtonPosition.right,
          bottom: widget.unreadMsgButtonPosition.bottom,
          child: _renderLastReadButton()),
      Positioned(
          top: widget.receivedMsgButtonPosition.top,
          left: widget.receivedMsgButtonPosition.left,
          right: widget.receivedMsgButtonPosition.right,
          bottom: widget.receivedMsgButtonPosition.bottom,
          child: _renderNewMessagesButtonOrScrollToTop()),
    ]);
  }

  @override
  void dispose() {
    listViewController.dispose();
    refreshController.dispose();
    super.dispose();
  }
}
