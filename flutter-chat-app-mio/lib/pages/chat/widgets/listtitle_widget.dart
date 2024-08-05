import 'package:chat/models/usuario.dart';
import 'package:chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListtitleWidget extends StatelessWidget {
  final Usuario usuario;
  const ListtitleWidget({required this.usuario});

  @override
  Widget build(BuildContext context) {
    print(usuario.last_message);
    bool isEmpty = false;
    if (usuario.last_message == null ||
        (usuario.last_message!.messages == '' &&
            usuario.last_message!.mediaType == 'text')) {
      isEmpty = true;
    }
    String from = usuario.last_message!.from == usuario.uid ? '' : 'Tú';
    Widget last_message_widget = Text(
      '¡Hola, habla conmigo!',
      style: TextStyle(
          fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
    );
    ;
    if (!isEmpty) {
      switch (usuario.last_message!.mediaType) {
        case 'audio':
          last_message_widget = selectLastMessage(
              usuario.last_message!.messages == '',
              'Audio',
              usuario.last_message!.messages,
              Icons.mic,
              from);
          break;
        case 'image':
          last_message_widget = selectLastMessage(
              usuario.last_message!.messages == '',
              'Foto',
              usuario.last_message!.messages,
              Icons.photo,
              from);
          break;
        case 'video':
          last_message_widget = selectLastMessage(
              usuario.last_message!.messages == '',
              'Video',
              usuario.last_message!.messages,
              Icons.video_collection,
              from);
          break;
        case 'text':
          last_message_widget = selectLastMessage(false, 'Texto',
              usuario.last_message!.messages, Icons.textsms_outlined, from);
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.usuarioPara = usuario;
        Navigator.pushNamed(context, 'chat');
      },
      child: Container(
        //si no tiene el color no funciona la función de tocar xd
        color: const Color.fromARGB(0, 244, 243, 243),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Stack(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40, // Ajusta el tamaño aquí
                  child: Text(
                    usuario.nombre.substring(0, 2),
                    style: TextStyle(fontSize: 24),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(width: 16), // Espacio entre el avatar y el texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            usuario.nombre,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          !isEmpty
                              ? SizedBox()
                              : Stack(
                                  children: [
                                    CustomPaint(
                                      size: Size(100, 20),
                                      painter: ParallelogramPainter(),
                                    ),
                                    Positioned(
                                      left: 14,
                                      top: 2,
                                      child: Text(
                                        'Está pa´ cosa',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                      last_message_widget,
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 70,
              top: 30,
              child: CircleAvatar(
                radius: 10, // Ajusta el radio para incluir el borde
                backgroundColor:
                    Color.fromARGB(255, 250, 250, 250), // Borde blanco
                child: CircleAvatar(
                  radius: 7, // Ajusta el radio interno
                  backgroundColor:
                      usuario.online ? Colors.green[300] : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row selectLastMessage(bool isEmpty, String mediaType, String message,
      IconData icon, String from) {
    return Row(
      children: [
        from != ''
            ? Text(
                '$from: ',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              )
            : SizedBox(),
        mediaType != 'Texto'
            ? Icon(
                icon,
                color: Colors.grey[400],
              )
            : SizedBox(),
        Expanded(
          child: Text(
            isEmpty ? mediaType : message,
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ParallelogramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
