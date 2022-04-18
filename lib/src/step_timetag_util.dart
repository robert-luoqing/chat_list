import 'timetag_util.dart';

class StepTimetagUtil extends TimetagUtil {
  /// 1. Add [addedMsgs] into [messages] and remove duplicated messages
  /// 2. Generate time tag amount [addedMsgs] (keep time tag in messages not to change)
  /// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
  /// after that 3hours, create a time tag each 3 hours
  /// Notice, messsages and addedMsgs should be already ordered by time dasc. It mean the function will not sort again
  @override
  List<T> mergeIncomeNewMessages<T>(
      {required List<T> messages,
      required bool isAddTop,
      required List<T> addedMsgs,
      required DateTime Function(T msg) getMsgTime,
      required bool Function(T msg) isTimeTagMsg,
      required T Function(DateTime time) onCreateTimeTag,
      required List<String> timeTagPolicies,
      required String Function(T msg) getMsgId,
      bool needRegenerateTimeTag = false}) {
    // create map to enhance performance
    var addedMsgMap = <String, T>{};
    for (var addedMsg in addedMsgs) {
      addedMsgMap[getMsgId(addedMsg)] = addedMsg;
    }

    var result = <T>[];

    // remove duplicate
    for (var msg in messages) {
      var newMsg = msg;
      if (!isTimeTagMsg(msg)) {
        var msgId = getMsgId(msg);
        if (addedMsgMap[msgId] != null) {
          newMsg = addedMsgMap[msgId]!;
          addedMsgMap.remove(msgId);
        }
        result.add(newMsg);
      } else {
        if (!needRegenerateTimeTag) {
          result.add(newMsg);
        }
      }
    }

    // remove duplicate msg
    var newAddedMsgs = <T>[];
    for (var addedMsg in addedMsgs) {
      if (addedMsgMap[getMsgId(addedMsg)] != null) {
        newAddedMsgs.add(addedMsg);
      }
    }
    if (!needRegenerateTimeTag) {
      newAddedMsgs = generateTimeTags(
          messages: newAddedMsgs,
          getMsgTime: getMsgTime,
          onCreateTimeTag: onCreateTimeTag,
          timeTagPolicies: timeTagPolicies);

      // Add to top, It mean load prev
      if (isAddTop) {
        for (var i = newAddedMsgs.length - 1; i >= 0; i--) {
          result.insert(0, newAddedMsgs[i]);
        }
      } else {
        result.addAll(newAddedMsgs);
      }
    } else {
      if (isAddTop) {
        for (var i = newAddedMsgs.length - 1; i >= 0; i--) {
          result.insert(0, newAddedMsgs[i]);
        }
      } else {
        result.addAll(newAddedMsgs);
      }

      result = generateTimeTags(
          messages: result,
          getMsgTime: getMsgTime,
          onCreateTimeTag: onCreateTimeTag,
          timeTagPolicies: timeTagPolicies);
    }

    return result;
  }

  /// Generate time tag amount [messages]
  /// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
  /// [timeTagPolicies] support {s,m,h,d}
  /// after that 3hours, create a time tag each 3 hours
  @override
  List<T> generateTimeTags<T>(
      {required List<T> messages,
      required DateTime Function(T) getMsgTime,
      required T Function(DateTime time) onCreateTimeTag,
      required List<String> timeTagPolicies}) {
    List<T> result = <T>[];
    var policies = parseTimeTagPolicies(timeTagPolicies);
    if (policies.isEmpty) {
      result = messages;
    } else {
      int curPoliIndex = 0;
      int curPolicy = policies[
          curPoliIndex >= policies.length ? policies.length : curPoliIndex];
      var nextPhraseTimestamp =
          DateTime.now().millisecondsSinceEpoch - curPolicy;
      for (var i = 0; i < messages.length; i++) {
        var curMsg = messages[i];
        var curMsgTime = getMsgTime(curMsg);
        var curMsgTimestamp = curMsgTime.millisecondsSinceEpoch;
        var needGenerateTimeTag = false;
        if (i == messages.length - 1) {
          needGenerateTimeTag = true;
        } else {
          var nextMsg = messages[i + 1];
          var nextMsgTimestamp = getMsgTime(nextMsg!).millisecondsSinceEpoch;

          while (true) {
            if (curMsgTimestamp >= nextPhraseTimestamp &&
                nextMsgTimestamp <= nextPhraseTimestamp) {
              needGenerateTimeTag = true;
              // Move next phase
              curPoliIndex++;
              curPolicy = policies[curPoliIndex >= policies.length
                  ? policies.length - 1
                  : curPoliIndex];
              nextPhraseTimestamp = nextPhraseTimestamp - curPolicy;
              break;
            } else if (curMsgTimestamp < nextPhraseTimestamp &&
                nextMsgTimestamp < nextPhraseTimestamp) {
              // Move next phase
              curPoliIndex++;
              curPolicy = policies[curPoliIndex >= policies.length
                  ? policies.length - 1
                  : curPoliIndex];
              nextPhraseTimestamp = nextPhraseTimestamp - curPolicy;
            } else {
              break;
            }
          }
        }

        result.add(curMsg);
        if (needGenerateTimeTag) {
          result.add(
              onCreateTimeTag(curMsgTime.add(const Duration(milliseconds: 1))));
        }
      }
    }

    return result;
  }
}
