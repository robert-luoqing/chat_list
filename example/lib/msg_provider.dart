import 'dart:math';

import 'package:chat_list_example/msg_model.dart';
import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

class MsgProvider {
  Future<List<MsgModel>> fetchMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<MsgModel> messages = [];
    for (var i = 0; i < 50; i++) {
      if (i != 9) {
        var msg = generateWordPairs().take(Random().nextInt(10)).toString();
        if (Random().nextInt(10) % 2 == 0) {
          insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1));
        } else {
          insertSendMessage(messages, msg * (Random().nextInt(2) + 1));
        }
      } else {
        insertReceiveMessage(messages, "Last readed message");
      }
    }

    return messages;
  }

  Future<List<MsgModel>> fetchMessagesWithKey(String key) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<MsgModel> messages = [];
    for (var i = 0; i < 50; i++) {
      if (i != 9) {
        var msg = generateWordPairs().take(Random().nextInt(10)).toString();
        if (Random().nextInt(10) % 2 == 0) {
          insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1));
        } else {
          insertSendMessage(messages, msg * (Random().nextInt(2) + 1));
        }
      } else {
        insertReceiveMessage(messages, "Last readed message", key: key);
      }
    }

    return messages;
  }

  List<MsgModel> getNewReceiveMsgList(int count) {
    List<MsgModel> messages = [];
    for (var i = 0; i < count; i++) {
      var msg = generateWordPairs().take(Random().nextInt(10)).toString();
      insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1));
    }

    return messages;
  }

  MsgModel insertSendMessage(List<MsgModel> messages, String msg,
      {bool appendToTailer = false}) {
    var time = DateTime.now();
    if (appendToTailer) {
      var msgObj = MsgModel(
          id: const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.sent,
          time: time);
      messages.add(msgObj);
      return msgObj;
    } else {
      var msgObj = MsgModel(
          id: const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.sent,
          time: time);
      messages.insert(0, msgObj);
      return msgObj;
    }
  }

  MsgModel insertReceiveMessage(List<MsgModel> messages, String msg,
      {bool appendToTailer = false, String? key}) {
    var time = DateTime.now();
    if (appendToTailer) {
      var msgObj = MsgModel(
          id: key ?? const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.receive,
          time: time);
      messages.add(msgObj);
      return msgObj;
    } else {
      var msgObj = MsgModel(
          id: key ?? const Uuid().v4(),
          msg: msg.trim(),
          type: MsgType.receive,
          time: time);
      messages.insert(0, msgObj);
      return msgObj;
    }
  }
}
