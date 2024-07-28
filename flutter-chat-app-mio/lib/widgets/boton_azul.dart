import 'package:flutter/material.dart';

class BotonAzul extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const BotonAzul({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: StadiumBorder(),
        backgroundColor: Colors.blue, // Color de fondo
        foregroundColor: Colors.white, // Color del texto
      ),
      onPressed: this.onPressed,
      child: Container(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(this.text,
              style: TextStyle(color: Colors.white, fontSize: 17)),
        ),
      ),
    );
  }
}
