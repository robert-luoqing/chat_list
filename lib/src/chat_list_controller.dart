import '../chat_list.dart';

class ChatListController {
  ChatListState? stateObj;
  notifyNewMessageComing(String firstKey) {
    stateObj?.notifyNewMessageComing(firstKey);
  }

  mount(ChatListState state) {
    stateObj = state;
  }
}
