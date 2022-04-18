import 'dart:math';

import 'package:chat_list_example/msg_model.dart';
import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

class MsgProvider {
  /// Loading [count] messages from [fromTimestamp]
  /// The statement should be time >=[fromTimestamp] order by time asc
  /// The list order by time by asc
  Future<List<MsgModel>> fetchMessagesFrom(int fromTimestamp, int count) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    List<MsgModel> messages = [];
    for (var i = 0; i < count; i++) {
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

  /// Loading [count] messages to [toTimestamp]
  /// There is difference from [fetchMessagesFrom], fetch record condition should be
  /// time <=[toTimestamp] order by time desc
  /// No matter query table by desc, The result value must order with time by asc
  Future<List<MsgModel>> fetchMessagesTo(int toTimestamp, int count) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    List<MsgModel> messages = [];
    for (var i = 0; i < count; i++) {
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

  /// When jump to specify key message, but the message not exist.
  /// We should load messages from providers
  /// The result value must order with time by asc
  Future<List<MsgModel>> fetchMessagesAroundKey(String msgId, int count) async {
    List<MsgModel> messages = [];
    var curMsg =
        insertReceiveMessage(messages, "Last readed message", key: msgId);
    // Get prev 10 message
    var prevMessages =
        await fetchMessagesTo(curMsg.time.millisecondsSinceEpoch, 60);
    var nextMessages =
        await fetchMessagesFrom(curMsg.time.millisecondsSinceEpoch, 10);

    var result = mergeAndRemoveDuplicateMsgs(prevMessages, [curMsg]);
    result = mergeAndRemoveDuplicateMsgs(result, nextMessages);
    result.sort(((a, b) =>
        a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch));
    var newResult = <MsgModel>[];
    // Fetch [count] item from tail to top
    for (var i = result.length - 1; i >= 0; i--) {
      newResult.insert(0, result[i]);
      if (newResult.length == count) break;
    }

    return newResult;
  }

  /// Merge message, remove duplicate record
  List<MsgModel> mergeAndRemoveDuplicateMsgs(
      List<MsgModel> msg1s, List<MsgModel> msg2s) {
    // create map
    var msgMaps = <String, MsgModel>{};
    var result = <MsgModel>[];
    for (var msg1 in msg1s) {
      if (msgMaps[msg1.id] == null) {
        msgMaps[msg1.id] = msg1;
        result.add(msg1);
      }
    }
    for (var msg2 in msg2s) {
      if (msgMaps[msg2.id] == null) {
        msgMaps[msg2.id] = msg2;
        result.add(msg2);
      }
    }

    return result;
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
