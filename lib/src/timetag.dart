/// 1. Add [addedMsgs] into [messages] and remove duplicated messages
/// 2. Generate time tag amount [addedMsgs] (keep time tag in messages not to change)
/// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
/// after that 3hours, create a time tag each 3 hours
/// Notice, messsages and addedMsgs should be already ordered by time asc. It mean the function will not sort again
List<T> mergeIncomeNewMessages<T>(
    {required List<T> messages,
    required bool isAddTop,
    required List<T> addedMsgs,
    required DateTime Function(T) getMessageTime,
    required bool Function() isTimeTagMsg,
    required T Function(DateTime time) onCreateTimeTag,
    required List<String> timeTagPolicies,
    required String Function(T msg1) getMsgId,
    bool needRegenerateTimeTag = false}) {
  // create map to enhance performance
  var addedMsgMap = <String, T>{};
  for (var addedMsg in addedMsgs) {
    addedMsgMap[getMsgId(addedMsg)] = addedMsg;
  }

  T? firstTimeTagMsg;
  T? lastTimeTagMsg;
  for (var msg in messages) {
    // if(istime)
  }

  return messages;
}

/// Generate time tag amount [messages]
/// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
/// [timeTagPolicies] support {s,m,h,d}
/// after that 3hours, create a time tag each 3 hours
List<T> generateTimeTags<T>(
    {required List<T> messages,
    required DateTime Function(T) getMessageTime,
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
    var nextPhraseTimestamp = DateTime.now().millisecondsSinceEpoch + curPolicy;
    for (var i = 0; i < messages.length; i++) {
      var curMsg = messages[i];
      var curMsgTime = getMessageTime(curMsg);
      var curMsgTimestamp = curMsgTime.millisecondsSinceEpoch;
      var needGenerateTimeTag = false;
      if (i == messages.length - 1) {
        needGenerateTimeTag = true;
      } else {
        var nextMsg = messages[i + 1];
        var nextMsgTimestamp = getMessageTime(nextMsg!).millisecondsSinceEpoch;

        while (true) {
          if (curMsgTimestamp <= nextPhraseTimestamp &&
              nextMsgTimestamp >= nextPhraseTimestamp) {
            needGenerateTimeTag = true;
            // Move next phase
            curPoliIndex++;
            curPolicy = policies[curPoliIndex >= policies.length
                ? policies.length
                : curPoliIndex];
            nextPhraseTimestamp = nextPhraseTimestamp + curPolicy;
            break;
          } else if (curMsgTimestamp > nextPhraseTimestamp &&
              nextMsgTimestamp > nextPhraseTimestamp) {
            // Move next phase
            curPoliIndex++;
            curPolicy = policies[curPoliIndex >= policies.length
                ? policies.length
                : curPoliIndex];
            nextPhraseTimestamp = nextPhraseTimestamp + curPolicy;
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
