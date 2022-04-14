import 'package:chat_list/chat_list.dart';
import 'package:chat_list_example/msg_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'msg_model.dart';

const UnreadMessageKey = "unreadId";

class TestChatList extends StatefulWidget {
  const TestChatList({Key? key}) : super(key: key);

  @override
  State<TestChatList> createState() => _TestChatListState();
}

class _TestChatListState extends State<TestChatList> {
  List<MsgModel>? messages;
  final inputMsgController = TextEditingController();
  final chatListController = ChatListController();
  String? latestMessageKey;

  bool hasPrevMessages = false;
  bool hasMoreMessages = true;

  @override
  void initState() {
    _loadMessages();
    latestMessageKey = UnreadMessageKey;
    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    messages = await MsgProvider().fetchMessages();
    // messages = await MsgProvider().fetchMessagesWithKey(UnreadMessageKey);
    // latestMessageKey = messages![messages!.length - 10].id;
    setState(() {});
  }

  _mockToReceiveMessage() {
    var receivedMsgs = MsgProvider().getNewReceiveMsgList(3);
    if (hasPrevMessages == false) {
      for (var receiveMsg in receivedMsgs) {
        messages?.insert(0, receiveMsg);
      }
    }

    chatListController.notifyNewMessageComing(receivedMsgs[0].id, 3);
    setState(() {});
  }

  Future _loadMoreMessagesWhileMissLatestMsg() async {
    messages = await MsgProvider().fetchMessagesWithKey(UnreadMessageKey);
    hasPrevMessages = true;
    setState(() {});
  }

  _sendMessage() {
    if (inputMsgController.text.isNotEmpty) {
      // if (messages.isNotEmpty) {
      //   listViewController.sliverController.jumpToIndex(0);
      // }
      messages ??= [];
      setState(() {
        MsgProvider().insertSendMessage(messages!, inputMsgController.text);
      });

      inputMsgController.text = "";
    }
  }

  _renderItem(int index) {
    var msg = messages![index];
    if (msg.type == MsgType.tag) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                msg.msg,
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: msg.type == MsgType.sent
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color: msg.type == MsgType.sent ? Colors.blue : Colors.green,
                borderRadius: msg.type == MsgType.sent
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                msg.msg,
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _renderScrollToTop(BuildContext context) {
    return Ink(
        child: Container(
      decoration: const BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Scroll to top"),
      ),
    ));
  }

  Widget _renderNewMessageTipButton(BuildContext context, int newMsgCount) {
    return Ink(
        child: Container(
      decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(newMsgCount.toString() + " new messages comming"),
      ),
    ));
  }

  Widget _lastReadMessageTipBuilder(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Latest read message",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _renderLoadWidget(BuildContext context, LoadStatus? mode) {
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
    return Container(
      color: Colors.red,
      child: SizedBox(
        height: 55.0,
        child: Center(child: body),
      ),
    );
  }

  Widget _renderRefreshWidget(BuildContext context, RefreshStatus? mode) {
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
        child: Container(
          color: Colors.yellow,
          child: SizedBox(
            height: 55.0,
            child: Center(child: body),
          ),
        ),
      );
    }
  }

  _renderList() {
    return ChatList(
        messageCount: messages?.length ?? 0,
        itemBuilder: (BuildContext context, int index) => _renderItem(index),
        onMessageKey: (int index) => messages![index].id,
        controller: chatListController,
        // New message tip
        showNewMessageComingButton: true,
        newMessageComingButtonPosition: const Position(right: 10, bottom: 20),
        newMessageComingButtonBuilder: _renderNewMessageTipButton,
        onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,

        // Scroll to top
        showScrollToTop: true,
        offsetToShowScrollToTop: 400.0,
        scrollToTopBuilder: _renderScrollToTop,
        loadTopMessagesWhenJumpToTop: () async {
          messages = await MsgProvider().fetchMessages();
          hasPrevMessages = false;
          setState(() {});
        },

        // Last read message
        showLastReadMessageButton: true,
        latestReadMessageKey: latestMessageKey,
        loadMoreMessagesWhileMissLatestMsg: _loadMoreMessagesWhileMissLatestMsg,
        lastUnreadMsgOffsetFromTop: 50,
        lastReadMessageTipBuilder: _lastReadMessageTipBuilder,

        // Load more
        hasMoreNextMessages: hasMoreMessages,
        loadNextMessageOffset: 10,
        loadPrevWidgetBuilder: _renderRefreshWidget,
        loadNextMessages: () async {
          var newMessages = await MsgProvider().fetchMessages();
          messages!.addAll(newMessages);
          if (messages!.length > 200) {
            hasMoreMessages = false;
          }
          setState(() {});
        },

        // Refresh
        hasMorePrevMessages: hasPrevMessages,
        loadPrevMessageOffset: 100,
        loadNextWidgetBuilder: _renderLoadWidget,
        loadPrevMessages: () async {
          var newMessages = await MsgProvider().fetchMessages();
          messages!.insertAll(0, newMessages);
          if (messages!.length > 200) {
            hasPrevMessages = false;
          }
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
          actions: [
            TextButton(
                onPressed: _mockToReceiveMessage,
                child: const Text(
                  "Mock To Receive",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(flex: 1, child: _renderList()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: inputMsgController,
                          ),
                        ),
                        ElevatedButton(
                            onPressed: _sendMessage, child: const Text("Send"))
                      ]),
                    )
                  ],
                ),
              ),
            )));
  }
}
