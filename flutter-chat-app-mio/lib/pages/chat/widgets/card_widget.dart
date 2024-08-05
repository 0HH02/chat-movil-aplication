import 'package:flutter/material.dart';

class CardChat extends StatelessWidget {
  const CardChat();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green, Colors.amber],
            transform: GradientRotation(0.5),
          ),
          borderRadius: BorderRadius.all(Radius.circular(7))),
      height: 130,
      width: 95,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    );
  }
}

class CardChatEspecial extends StatelessWidget {
  const CardChatEspecial();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 91, 79),
              borderRadius: BorderRadius.all(Radius.circular(7))),
          height: 130,
          width: 95,
          margin: EdgeInsets.symmetric(horizontal: 5),
        ),
        Positioned(
          top: 40,
          left: 30,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 196, 0),
                borderRadius: BorderRadius.circular(100)),
            child: Center(
              child: Text(
                '99+',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }
}
