import 'package:chat/models/messages.dart';
import 'package:chat/pages/chat/utils/colors.dart';
import 'package:chat/pages/chat/widgets/seen_widget.dart';
import 'package:chat/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BubbleChat extends StatefulWidget {
  final Widget message;
  final bool seen;
  final bool myMessage;
  final bool multimedia;
  final PrivateMessages messages;

  BubbleChat(
      {Key? key,
      required this.message,
      required this.seen,
      required this.myMessage,
      required this.multimedia,
      required this.messages})
      : super(key: key);

  @override
  _BubbleChatState createState() => _BubbleChatState();
}

class _BubbleChatState extends State<BubbleChat>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0.0;
  double _dragStartX = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX = details.localPosition.dx - _dragStartX;
      if (_offsetX > 200) _offsetX = 200;
      if (_offsetX < 0) _offsetX = 0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    print(_offsetX);
    if (_offsetX >= 100) {
      Provider.of<MessageService>(context, listen: false)
          .setReference(widget.messages);
    }
    final offset = _offsetX;
    _animation = Tween<double>(begin: offset, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    )..addListener(() {
        setState(() {
          _offsetX = _animation.value;
        });
      });

    _animationController.duration = Duration(milliseconds: 500);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: widget.myMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    right: widget.myMessage ? 10 : 0,
                    left: widget.myMessage ? 0 : 10),
                child: Column(
                  crossAxisAlignment: widget.myMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.multimedia ? 4 : 8.0),
                      margin: EdgeInsets.only(
                          bottom: 2,
                          left: widget.myMessage ? 50 : 0,
                          right: widget.myMessage ? 0 : 50),
                      child: Column(
                        children: [widget.message],
                      ),
                      decoration: BoxDecoration(
                          color: widget.myMessage
                              ? LigueColors.myBurbbleChat
                              : LigueColors.otherBurbbleChat,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft:
                                  Radius.circular(widget.myMessage ? 15 : 5),
                              bottomRight:
                                  Radius.circular(widget.myMessage ? 5 : 15))),
                    ),
                    SeenWidget(
                      seen: widget.seen,
                      hour: _getHour(widget.messages.date),
                      myMessage: widget.myMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHour(String date) {
    String hour =
        (int.parse(date.split(' ')[1].substring(0, 2)) % 12).toString();
    return '$hour${date.split(' ')[1].substring(2, 5)}';
  }
}
