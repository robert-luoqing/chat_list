import 'package:flutter_chat_list/chat_list.dart';
import 'package:chat_list_example/msg_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

import 'msg_model.dart';
import 'text_msg.dart';
import 'time_tag_msg.dart';

class SimpleChatList extends StatefulWidget {
  const SimpleChatList({Key? key}) : super(key: key);

  @override
  State<SimpleChatList> createState() => _SimpleChatListState();
}

class _SimpleChatListState extends State<SimpleChatList> {
  List<MsgModel>? messages;
  final inputMsgController = TextEditingController();
  final chatListController = ChatListController();
  final timetagUtil = StepTimetagUtil();
  final timeTagPolicies = ["2m", "5m", "10m", "30m", "2h"];

  @override
  void initState() {
    _loadMessages();
    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    EasyLoading.show(status: 'loading...');
    try {
      messages = await MsgProvider().fetchMessagesFrom(0, 40);
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

  _mockToReceiveMessage() {
    var receivedMsgs = MsgProvider().getNewReceiveMsgList(3);

    messages ??= [];
    messages = timetagUtil.mergeIncomeNewMessages(
        messages: messages!,
        isAddTop: true,
        addedMsgs: receivedMsgs,
        getMsgTime: (msg) => msg.time,
        isTimeTagMsg: (msg) => msg.type == MsgType.timetag,
        onCreateTimeTag: (time) => MsgModel(
            id: const Uuid().v4(), msg: "", type: MsgType.timetag, time: time),
        timeTagPolicies: timeTagPolicies,
        getMsgId: (msg) => msg.id);

    chatListController.notifyNewMessageComing(receivedMsgs[0].id, 3);
    setState(() {});
  }

  _sendMessage() {
    try {
      if (inputMsgController.text.isNotEmpty) {
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
      msgCount: messages?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => _renderItem(index),
      onMsgKey: (int index) => messages![index].id,
      controller: chatListController,
      // New message tip
      showReceivedMsgButton: true,
      onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,

      // Scroll to top
      showScrollToTopButton: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Simple Chat"),
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
