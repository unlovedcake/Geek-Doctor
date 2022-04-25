class Message {
  final String? sender;
  final String? avatar;
  final DateTime? time;
  final int? unreadCount;
  final bool? isRead;
  final String? text;

  Message({
    this.sender,
    this.avatar,
    this.time,
    this.unreadCount,
    this.text,
    this.isRead,
  });
}
