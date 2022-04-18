import 'package:flutter/widgets.dart';

import '../chat_list.dart';

class ChatListController {
  ChatListState? stateObj;
  notifyNewMessageComing(String firstKey, int newMsgCount) {
    stateObj?.notifyNewMessageComing(firstKey, newMsgCount);
  }

  jumpToIndex(int index) {
    stateObj?.listViewController.sliverController.jumpToIndex(index);
  }

  Future<void> animateToIndex(
    int index, {
    required Duration duration,
    required Curve curve,
    double offset = 0,
    bool offsetBasedOnBottom = false,
  }) async {
    stateObj?.listViewController.sliverController.animateToIndex(index,
        duration: duration,
        curve: curve,
        offset: offset,
        offsetBasedOnBottom: offsetBasedOnBottom);
  }

  mount(ChatListState state) {
    stateObj = state;
  }
}
