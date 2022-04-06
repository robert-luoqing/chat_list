import 'dart:math';

import 'package:chat_list_example/msg_model.dart';
import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

class MsgProvider {
  Future<List<MsgModel>> fetchMessages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    List<MsgModel> messages = [];
    for (var i = 0; i < 50; i++) {
      var msg = generateWordPairs().take(Random().nextInt(10)).toString();
      if (Random().nextInt(10) % 2 == 0) {
        insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1));
      } else {
        insertSendMessage(messages, msg * (Random().nextInt(2) + 1));
      }
    }

    return messages;
  }

  insertSendMessage(List<MsgModel> messages, String msg,
      {bool appendToTailer = false}) {
    var time = DateTime.now();
    if (appendToTailer) {
      messages.add(MsgModel(
          id: const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.sent,
          time: time));
    } else {
      messages.insert(
          0,
          MsgModel(
              id: const Uuid().v4(),
              msg: msg.trim(),
              type: MsgType.sent,
              time: time));
    }
  }

  insertReceiveMessage(List<MsgModel> messages, String msg,
      {bool appendToTailer = false}) {
    var time = DateTime.now();
    if (appendToTailer) {
      messages.add(MsgModel(
          id: const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.receive,
          time: time));
    } else {
      messages.insert(
          0,
          MsgModel(
              id: const Uuid().v4(),
              msg: msg.trim(),
              type: MsgType.receive,
              time: time));
    }
  }
}
