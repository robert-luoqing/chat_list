import 'package:chat_list/src/step_timetag_util.dart';
import 'package:flutter_test/flutter_test.dart';

class MsgTestModel {
  MsgTestModel({required this.id, required this.type, required this.time});
  String id;
  MsgTestType type;
  DateTime time;
}

enum MsgTestType {
  sent,
  receive,
  timetag,
}

MsgTestModel addMsg(int id, double mins) {
  var millSeconds = (1000 * 60 * mins).toInt();
  var time = DateTime.now().add(Duration(milliseconds: -millSeconds));
  return MsgTestModel(id: id.toString(), type: MsgTestType.receive, time: time);
}

void main() {
  test('normal test step timetag', () {
    int id = 1;
    var messages = <MsgTestModel>[];
    messages.add(addMsg(id++, 1));
    messages.add(addMsg(id++, 1.5));
    // 1 tag should here
    messages.add(addMsg(id++, 2.2));
    // 2 tag should here
    messages.add(addMsg(id++, 10.1));
    // 3 tag should here

    var timetag = StepTimetagUtil();
    var result = timetag.generateTimeTags<MsgTestModel>(
        messages: messages,
        getMsgTime: (msg) => msg.time,
        onCreateTimeTag: (time) {
          return MsgTestModel(
              id: (id++).toString(), type: MsgTestType.timetag, time: time);
        },
        timeTagPolicies: ["2m", "2m", "10m"]);
    expect(result.length, 7);
    expect(result[2].type, MsgTestType.timetag);
    expect(result[4].type, MsgTestType.timetag);
    expect(result[6].type, MsgTestType.timetag);
  });

  test('normal test step timetag2', () {
    int id = 1;
    var messages = <MsgTestModel>[];
    messages.add(addMsg(id++, 1));
    messages.add(addMsg(id++, 1.5));
    // 1 tag should here
    messages.add(addMsg(id++, 10.1));
    // 2 tag should here

    var timetag = StepTimetagUtil();
    var result = timetag.generateTimeTags<MsgTestModel>(
        messages: messages,
        getMsgTime: (msg) => msg.time,
        onCreateTimeTag: (time) {
          return MsgTestModel(
              id: (id++).toString(), type: MsgTestType.timetag, time: time);
        },
        timeTagPolicies: ["2m", "2m", "10m"]);
    expect(result.length, 5);
    expect(result[2].type, MsgTestType.timetag);
    expect(result[4].type, MsgTestType.timetag);
  });

  test('normal test step timetag3', () {
    int id = 1;
    var messages = <MsgTestModel>[];
    messages.add(addMsg(id++, 2.2));
    // 1 tag should here
    messages.add(addMsg(id++, 10.1));
    // 2 tag should here

    var timetag = StepTimetagUtil();
    var result = timetag.generateTimeTags<MsgTestModel>(
        messages: messages,
        getMsgTime: (msg) => msg.time,
        onCreateTimeTag: (time) {
          return MsgTestModel(
              id: (id++).toString(), type: MsgTestType.timetag, time: time);
        },
        timeTagPolicies: ["2m", "2m", "10m"]);
    expect(result.length, 4);
    expect(result[1].type, MsgTestType.timetag);
    expect(result[3].type, MsgTestType.timetag);
  });
}
