import 'package:chat_list/chat_list.dart';
import 'package:chat_list_example/msg_provider.dart';
import 'package:flutter/material.dart';

import 'msg_model.dart';

class TestChatList extends StatefulWidget {
  const TestChatList({Key? key}) : super(key: key);

  @override
  State<TestChatList> createState() => _TestChatListState();
}

class _TestChatListState extends State<TestChatList> {
  List<MsgModel>? messages;
  final inputMsgController = TextEditingController();

  @override
  void initState() {
    _loadMessages();

    super.initState();
  }

  /// It is mockup to load messages from server
  _loadMessages() async {
    messages = await MsgProvider().fetchMessages();
    setState(() {});
  }

  _mockToReceiveMessage() {
    // var times = Random().nextInt(4) + 1;
    // for (var i = 0; i < times; i++) {
    //   _insertReceiveMessage("The demo also show how to reverse a list in\r\n" *
    //       (Random().nextInt(4) + 1));
    // }
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

  _renderList() {
    return ChatList(
        messageCount: messages?.length ?? 0,
        itemBuilder: (BuildContext context, int index) => _renderItem(index),
        onMessageKey: (int index) => messages![index].id);
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
