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

  /// 1. Add [addedMsgs] into [messages] and remove duplicated messages
  /// 2. Generate time tag amount [addedMsgs] (keep time tag in messages not to change)
  /// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
  /// after that 3hours, create a time tag each 3 hours
  List<T> mergeIncomeNewMessages<T>(
      {required List<T> messages,
      required bool isAddTop,
      required List<T> addedMsgs,
      required DateTime Function(T) getMessageTime,
      required bool Function() isTimeTagMsg,
      required T Function(DateTime time) onCreateTimeTag,
      required List<String> timeTagPolicies,
      bool needRegenerateTimeTag = false}) {
    return messages;
  }

  /// Generate time tag amount [messages]
  /// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
  /// after that 3hours, create a time tag each 3 hours
  List<T> generateTimeTags<T>({
    required List<T> messages,
    required DateTime Function(T) getMessageTime,
    required T Function(DateTime time) onCreateTimeTag,
    required List<String> timeTagPolicies
  }) {
    List<T> result = <T>[];
    var policies = parseTimeTagPolicies(timeTagPolicies);
    if (policies.isEmpty) {
      result = messages;
    } else {
      int curPolIndex = 0;
      int curPolicy = policies[
          curPolIndex >= policies.length ? policies.length : curPolIndex];
      for (var msg in messages) {
        var msgTime = getMessageTime(msg);
      }
    }

    return result;
  }

  List<int> parseTimeTagPolicies(List<String> timeTagPolicies) {
    var result = <int>[];
    for (var policy in timeTagPolicies) {
      var endStr = policy.substring(policy.length - 1);
      var prefixNum = policy.substring(0, policy.length - 1);
      if (endStr == "s") {
        result.add(int.parse(prefixNum) * 1000);
      } else if (endStr == "m") {
        result.add(int.parse(prefixNum) * 1000 * 60);
      } else if (endStr == "h") {
        result.add(int.parse(prefixNum) * 1000 * 60 * 60);
      } else if (endStr == "d") {
        result.add(int.parse(prefixNum) * 1000 * 60 * 60 * 24);
      }
    }

    result.sort((a, b) => a - b);
    return result;
  }
}
