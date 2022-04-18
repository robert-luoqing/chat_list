import 'dart:math';

import 'package:chat_list_example/msg_model.dart';
import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

class MsgProvider {
  /// Loading [count] messages from [fromTimestamp]
  /// The statement should be time >=[fromTimestamp] order by time desc
  /// The list order by time by desc
  Future<List<MsgModel>> fetchMessagesFrom(int fromTimestamp, int count) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    List<MsgModel> messages = [];
    var startTimestampInterval = 12;
    for (var i = 0; i < count; i++) {
      var msg = generateWordPairs().take(Random().nextInt(10)).toString();
      if (Random().nextInt(10) % 2 == 0) {
        insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1),
            seconds: startTimestampInterval,
            from: DateTime.fromMillisecondsSinceEpoch(fromTimestamp == 0
                ? DateTime.now().millisecondsSinceEpoch
                : fromTimestamp),
            appendToTailer: true);
      } else {
        insertSendMessage(messages, msg * (Random().nextInt(2) + 1),
            seconds: startTimestampInterval,
            from: DateTime.fromMillisecondsSinceEpoch(fromTimestamp == 0
                ? DateTime.now().millisecondsSinceEpoch
                : fromTimestamp),
            appendToTailer: true);
      }

      startTimestampInterval += Random().nextInt(60 * 2);
    }

    return messages;
  }

  /// Loading [count] messages to [toTimestamp]
  /// There is difference from [fetchMessagesFrom], fetch record condition should be
  /// time <=[toTimestamp] order by time asc
  /// No matter query table by desc, The result value must order with time by asc
  Future<List<MsgModel>> fetchMessagesTo(int toTimestamp, int count) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    List<MsgModel> messages = [];
    var startTimestampInterval = 12;
    for (var i = 0; i < count; i++) {
      var msg = generateWordPairs().take(Random().nextInt(10)).toString();
      if (Random().nextInt(10) % 2 == 0) {
        insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1),
            seconds: startTimestampInterval, appendToTailer: true);
      } else {
        insertSendMessage(messages, msg * (Random().nextInt(2) + 1),
            seconds: startTimestampInterval, appendToTailer: true);
      }

      startTimestampInterval += Random().nextInt(60 * 2);
    }

    return messages;
  }

  Future<List<MsgModel>> fetchMessagesAroundKey(String msgId, int count) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<MsgModel> messages = [];
    var startTimestampInterval = 12;
    for (var i = 0; i < count; i++) {
      if (i != count - 9) {
        var msg = generateWordPairs().take(Random().nextInt(10)).toString();
        if (Random().nextInt(10) % 2 == 0) {
          insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1),
              seconds: startTimestampInterval, appendToTailer: true);
        } else {
          insertSendMessage(messages, msg * (Random().nextInt(2) + 1),
              seconds: startTimestampInterval, appendToTailer: true);
        }
      } else {
        insertReceiveMessage(messages, "Last readed message",
            seconds: startTimestampInterval, key: msgId, appendToTailer: true);
      }
      startTimestampInterval += Random().nextInt(60 * 2);
    }

    return messages;
  }

  List<MsgModel> getNewReceiveMsgList(int count) {
    List<MsgModel> messages = [];
    for (var i = 0; i < count; i++) {
      var msg = generateWordPairs().take(Random().nextInt(10)).toString();
      insertReceiveMessage(messages, msg * (Random().nextInt(2) + 1),
          seconds: i + 10);
    }

    return messages;
  }

  MsgModel insertSendMessage(List<MsgModel> messages, String msg,
      {bool appendToTailer = false, DateTime? from, int seconds = 0}) {
    from ??= DateTime.now();
    var millSeconds = 1000 * seconds;
    var time = from.add(Duration(milliseconds: -millSeconds));
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
      {bool appendToTailer = false,
      String? key,
      DateTime? from,
      int seconds = 0}) {
    from ??= DateTime.now();
    var millSeconds = 1000 * seconds;
    var time = from.add(Duration(milliseconds: -millSeconds));
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
