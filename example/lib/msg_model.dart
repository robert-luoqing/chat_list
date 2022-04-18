class MsgModel {
  MsgModel(
      {required this.id,
      required this.msg,
      required this.type,
      required this.time});
  String id;
  String msg;
  MsgType type;
  DateTime time;
}

enum MsgType {
  sent,
  receive,
  timetag,
}
