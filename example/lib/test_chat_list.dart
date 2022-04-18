import 'package:chat_list/chat_list.dart';
import 'package:chat_list_example/msg_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

import 'msg_model.dart';
import 'text_msg.dart';
import 'time_tag_msg.dart';

const unreadMessageKey = "unreadId";

class TestChatList extends StatefulWidget {
  const TestChatList({Key? key}) : super(key: key);

  @override
  State<TestChatList> createState() => _TestChatListState();
}

class _TestChatListState extends State<TestChatList> {
  List<MsgModel>? messages;
  final inputMsgController = TextEditingController();
  final chatListController = ChatListController();
  final timetagUtil = StepTimetagUtil();
  final timeTagPolicies = ["2m", "5m", "10m", "30m", "2h"];
  String? latestMessageKey;
  int unreadMsgCount = 0;

  bool hasPrevMessages = false;
  bool hasMoreMessages = true;

  /// if [hasPrevMessages] is true, the [prevLoadedMsgTimestamp] has a value tell widget load previous messages to [prevLoadedMsgTimestamp]
  /// if [hasMoreMessages] is true, the [latestLoadedMsgTimestamp] has a value tell widget load more messages to [latestLoadedMsgTimestamp]
  int? prevLoadedMsgTimestamp;
  int latestLoadedMsgTimestamp = 0;

  @override
  void initState() {
    _loadMessages();
    latestMessageKey = unreadMessageKey;
    unreadMsgCount = 80;
    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    EasyLoading.show(status: 'loading...');
    try {
      hasPrevMessages = false;
      messages =
          await MsgProvider().fetchMessagesFrom(latestLoadedMsgTimestamp, 40);
      // messages = await MsgProvider().fetchMessagesWithKey(UnreadMessageKey);
      hasMoreMessages = (messages!.length == 40);
      if (messages!.isNotEmpty) {
        latestLoadedMsgTimestamp = messages!.last.time.millisecondsSinceEpoch;
      }
      messages = timetagUtil.generateTimeTags(
          messages: messages!,
          getMsgTime: (msg) => msg.time,
          onCreateTimeTag: (time) => MsgModel(
              id: const Uuid().v4(),
              msg: "",
              type: MsgType.timetag,
              time: time),
          timeTagPolicies: timeTagPolicies);
      setState(() {});
    } catch (e, s) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future _loadMoreMessagesWhileMissLatestMsg() async {
    EasyLoading.show(status: 'loading...');
    try {
      messages =
          await MsgProvider().fetchMessagesAroundKey(unreadMessageKey, 40);
      hasPrevMessages = (messages!.length == 40);
      hasMoreMessages = true;
      if (messages!.isNotEmpty) {
        latestLoadedMsgTimestamp = messages!.last.time.millisecondsSinceEpoch;
      }
      if (hasPrevMessages) {
        prevLoadedMsgTimestamp = messages!.first.time.millisecondsSinceEpoch;
      }

      messages = timetagUtil.generateTimeTags(
          messages: messages!,
          getMsgTime: (msg) => msg.time,
          onCreateTimeTag: (time) => MsgModel(
              id: const Uuid().v4(),
              msg: "",
              type: MsgType.timetag,
              time: time),
          timeTagPolicies: timeTagPolicies);

      setState(() {});
    } catch (e, s) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future _loadTopMessagesWhenJumpToTop() async {
    await _loadMessages();
  }

  /// The method don't need try catch
  Future _loadMoreMessages() async {
    var newMessages =
        await MsgProvider().fetchMessagesFrom(latestLoadedMsgTimestamp, 40);
    hasMoreMessages = (newMessages.length == 40);
    if (newMessages.isNotEmpty) {
      latestLoadedMsgTimestamp = newMessages.last.time.millisecondsSinceEpoch;
    }

    messages = timetagUtil.mergeIncomeNewMessages(
        messages: messages!,
        isAddTop: false,
        addedMsgs: newMessages,
        getMsgTime: (msg) => msg.time,
        isTimeTagMsg: (msg) => msg.type == MsgType.timetag,
        onCreateTimeTag: (time) => MsgModel(
            id: const Uuid().v4(), msg: "", type: MsgType.timetag, time: time),
        timeTagPolicies: timeTagPolicies,
        getMsgId: (msg) => msg.id);

    setState(() {});
  }

  /// The method don't need try catch
  Future _loadPrevMessages() async {
    var newMessages =
        await MsgProvider().fetchMessagesTo(prevLoadedMsgTimestamp ?? 0, 40);
    hasPrevMessages = (newMessages.length == 40);
    if (hasPrevMessages) {
      prevLoadedMsgTimestamp = newMessages.first.time.millisecondsSinceEpoch;
    }

    messages = timetagUtil.mergeIncomeNewMessages(
        messages: messages!,
        isAddTop: true,
        addedMsgs: newMessages,
        getMsgTime: (msg) => msg.time,
        isTimeTagMsg: (msg) => msg.type == MsgType.timetag,
        onCreateTimeTag: (time) => MsgModel(
            id: const Uuid().v4(), msg: "", type: MsgType.timetag, time: time),
        timeTagPolicies: timeTagPolicies,
        getMsgId: (msg) => msg.id);

    setState(() {});
  }

  _mockToReceiveMessage() {
    var receivedMsgs = MsgProvider().getNewReceiveMsgList(3);
    if (hasPrevMessages == false) {
      messages ??= [];
      messages = timetagUtil.mergeIncomeNewMessages(
          messages: messages!,
          isAddTop: true,
          addedMsgs: receivedMsgs,
          getMsgTime: (msg) => msg.time,
          isTimeTagMsg: (msg) => msg.type == MsgType.timetag,
          onCreateTimeTag: (time) => MsgModel(
              id: const Uuid().v4(),
              msg: "",
              type: MsgType.timetag,
              time: time),
          timeTagPolicies: timeTagPolicies,
          getMsgId: (msg) => msg.id);
    }

    chatListController.notifyNewMessageComing(receivedMsgs[0].id, 3);
    setState(() {});
  }

  _sendMessage() {
    try {
      if (inputMsgController.text.isNotEmpty) {
        // if (messages!=null && messages.isNotEmpty) {
        //   listViewController.sliverController.jumpToIndex(0);
        // }
        messages ??= [];
        setState(() {
          MsgProvider().insertSendMessage(messages!, inputMsgController.text,
              seconds: 0);
        });

        inputMsgController.text = "";
      }
    } catch (e, s) {
      EasyLoading.showError(e.toString());
    }
  }

  _renderItem(int index) {
    var msg = messages![index];
    if (msg.type == MsgType.timetag) {
      return TimetagMsg(message: msg);
    } else {
      return TextMsg(message: msg);
    }
  }

  Widget _renderList() {
    return ChatList(
      messageCount: messages?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => _renderItem(index),
      onMessageKey: (int index) => messages![index].id,
      controller: chatListController,
      // New message tip
      showNewMessageComingButton: true,
      newMessageComingButtonPosition: const Position(right: 0, bottom: 20),
      // newMessageComingButtonBuilder: defaultNewMessageComingButtonBuilder,
      onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,

      // Scroll to top
      showScrollToTop: true,
      offsetToShowScrollToTop: 400.0,
      // scrollToTopBuilder: defaultScrollToTopBuilder,
      loadTopMessagesWhenJumpToTop: _loadTopMessagesWhenJumpToTop,

      // Last read message
      showLastReadMessageButton: true,
      latestReadMessageKey: latestMessageKey,
      latestUnreadMsgCount: unreadMsgCount,
      lastReadMessageButtonPosition: const Position(right: 0, top: 20),
      loadMoreMessagesWhileMissLatestMsg: _loadMoreMessagesWhileMissLatestMsg,
      lastUnreadMsgOffsetFromTop: 50,
      // lastReadMessageButtonBuilder: defaultLastReadMessageButtonBuilder,

      // Refresh
      hasMorePrevMessages: hasPrevMessages,
      loadPrevMessageOffset: 100,
      loadPrevWidgetBuilder: defaultLoadPrevWidgetBuilder,
      loadPrevMessages: _loadPrevMessages,

      // Load more
      hasMoreNextMessages: hasMoreMessages,
      loadNextMessageOffset: 10,
      loadNextWidgetBuilder: defaultLoadNextWidgetBuilder,
      loadNextMessages: _loadMoreMessages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Complex Chat"),
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
            child: Container(
              color: Colors.grey[100],
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
                              onPressed: _sendMessage,
                              child: const Text("Send"))
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
