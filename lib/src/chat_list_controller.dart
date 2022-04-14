import '../chat_list.dart';

class ChatListController {
  ChatListState? stateObj;
  notifyNewMessageComing(String firstKey, int newMsgCount) {
    stateObj?.notifyNewMessageComing(firstKey, newMsgCount);
  }

  mount(ChatListState state) {
    stateObj = state;
  }
}
