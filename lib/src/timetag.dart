abstract class Timetag {
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
      bool needRegenerateTimeTag = false});

  /// Generate time tag amount [messages]
  /// if [timeTagPolicies] is ["5m", "20m", "1h", "3h"], is mean create a tag in 5min, 20min, 1hour and 3 hour,
  /// [timeTagPolicies] support {s,m,h,d}
  /// after that 3hours, create a time tag each 3 hours
  List<T> generateTimeTags<T>(
      {required List<T> messages,
      required DateTime Function(T) getMessageTime,
      required T Function(DateTime time) onCreateTimeTag,
      required List<String> timeTagPolicies});

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
