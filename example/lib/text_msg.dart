import 'package:chat_list_example/msg_model.dart';
import 'package:flutter/material.dart';

import 'bubble.dart';

class TextMsg extends StatefulWidget {
  const TextMsg({Key? key, required this.message}) : super(key: key);

  final MsgModel message;

  @override
  State<TextMsg> createState() => _TextMsgState();
}

class _TextMsgState extends State<TextMsg> {
  @override
  Widget build(BuildContext context) {
    var msg = widget.message;
    var content = Bubble(
        color: msg.type == MsgType.receive
            ? Colors.white
            : const Color.fromARGB(255, 87, 201, 90),
        child: Text(
          msg.msg,
          style: const TextStyle(fontSize: 14.0, color: Colors.black),
        ),
        direction: msg.type == MsgType.receive
            ? BubbleDirection.left
            : BubbleDirection.right);
    const gapWidget = SizedBox(
      width: 52,
    );
    var textWidget = Align(
      alignment: msg.type == MsgType.sent
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(padding: const EdgeInsets.all(10.0), child: content),
    );
    var avatarWidget = ClipOval(
        child: Image.asset(
      msg.type == MsgType.sent ? "assets/avatar1.png" : "assets/avatar2.png",
      width: 52,
      height: 52,
    ));

    if (msg.type == MsgType.sent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapWidget,
            Expanded(flex: 1, child: textWidget),
            avatarWidget,
          ],
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatarWidget,
              Expanded(flex: 1, child: textWidget),
              gapWidget
            ],
          ));
    }
  }
}
