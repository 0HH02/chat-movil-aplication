import 'package:chat/pages/chat/utils/colors.dart';
import 'package:flutter/material.dart';

class SeenWidget extends StatefulWidget {
  final bool myMessage;
  final bool seen;
  final String hour;
  const SeenWidget(
      {Key? key,
      required this.seen,
      required this.hour,
      required this.myMessage})
      : super(key: key);

  @override
  State<SeenWidget> createState() => _SeenWidgetState();
}

class _SeenWidgetState extends State<SeenWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.hour,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500]),
        ),
        widget.myMessage
            ? SizedBox(
                width: 5,
              )
            : const SizedBox(),
        widget.myMessage
            ? Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: LigueColors.myBurbbleChat),
                child: widget.seen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 3),
                        child: Stack(
                          children: [
                            Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                            Positioned(
                                left: 6,
                                child: Icon(Icons.check,
                                    size: 10, color: Colors.white)),
                          ],
                        ),
                      )
                    : Center(
                        child:
                            Icon(Icons.check, size: 12, color: Colors.white)),
              )
            : const SizedBox(),
      ],
    );
  }
}
