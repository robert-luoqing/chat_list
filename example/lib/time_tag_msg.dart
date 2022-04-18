import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import 'msg_model.dart';

class TimetagMsg extends StatefulWidget {
  const TimetagMsg({Key? key, required this.message}) : super(key: key);

  final MsgModel message;

  @override
  State<TimetagMsg> createState() => _TimetagMsgState();
}

class _TimetagMsgState extends State<TimetagMsg> {
  @override
  Widget build(BuildContext context) {
    var msg = widget.message;
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          formatDate(msg.time, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]),
          style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
