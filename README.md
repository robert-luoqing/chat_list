## Chat List

Chat list library is based on flutter list view library to implement full chat list functionality.

## Features

1. Support loading more and loading previous messages.
2. Support keeping scroll position when user scroll to other position to read messages.  
3. Support scrolling to unread message.
4. Support detecting receive message and tip new received messages
5. Support timetag in messages
6. Support load fragment messages and infine load prev messages

## Screen
![](screen/message.png)

## Example
```dart
Widget _renderList() {
  return ChatList(
    messageCount: messages?.length ?? 0,
    itemBuilder: (BuildContext context, int index) => _renderItem(index),
    onMessageKey: (int index) => messages![index].id,
    controller: chatListController,
    // New message tip
    showNewMessageComingButton: true,
    onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,

    // Scroll to top
    showScrollToTop: true,
  );
}
```
More complex example
```dart
Widget _renderList() {
  return ChatList(
    messageCount: messages?.length ?? 0,
    itemBuilder: (BuildContext context, int index) => _renderItem(index),
    onMessageKey: (int index) => messages![index].id,
    controller: chatListController,
    // New message tip
    showNewMessageComingButton: true,
    newMessageComingButtonPosition: const Position(right: 0, bottom: 20),
    // newMessageComingButtonBuilder: defaultNewMessageComingButtonBuilder,
    onIsReceiveMessage: (int i) => messages![i].type == MsgType.receive,

    // Scroll to top
    showScrollToTop: true,
    offsetToShowScrollToTop: 400.0,
    // scrollToTopBuilder: defaultScrollToTopBuilder,
    loadTopMessagesWhenJumpToTop: _loadTopMessagesWhenJumpToTop,

    // Last read message
    showLastReadMessageButton: true,
    latestReadMessageKey: latestMessageKey,
    latestUnreadMsgCount: unreadMsgCount,
    lastReadMessageButtonPosition: const Position(right: 0, top: 20),
    loadMoreMessagesWhileMissLatestMsg: _loadMoreMessagesWhileMissLatestMsg,
    lastUnreadMsgOffsetFromTop: 50,
    // lastReadMessageButtonBuilder: defaultLastReadMessageButtonBuilder,

    // Refresh
    hasMorePrevMessages: hasPrevMessages,
    loadPrevMessageOffset: 100,
    loadPrevWidgetBuilder: defaultLoadPrevWidgetBuilder,
    loadPrevMessages: _loadPrevMessages,

    // Load more
    hasMoreNextMessages: hasMoreMessages,
    loadNextMessageOffset: 10,
    loadNextWidgetBuilder: defaultLoadNextWidgetBuilder,
    loadNextMessages: _loadMoreMessages,
  );
}

```