import 'package:chat/models/ligues.dart';
import 'package:chat/pages/chat/widgets/card_widget.dart';
import 'package:chat/pages/chat/widgets/listtitle_widget.dart';
import 'package:chat/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/usuarios_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/models/usuario.dart';

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuarioService = new UsuariosService();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Usuario> usuarios = [];
  List<PosiblesLigues> posiblesLigues = [
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
    PosiblesLigues(
        online: false, nombre: "María", uid: "1", photo: "image1.jpg"),
  ];

  @override
  void initState() {
    this._cargarUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    final usuario = authService.usuario;

    return Scaffold(
        appBar: AppBar(
          title: Text(usuario.nombre, style: TextStyle(color: Colors.black87)),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black87),
            onPressed: () {
              socketService.disconnect();
              Navigator.pushReplacementNamed(context, 'login');
              AuthService.deleteToken();
            },
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle, color: Colors.blue[400])
                  : Icon(Icons.offline_bolt, color: Colors.red),
            )
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _cargarUsuarios,
          header: WaterDropHeader(
            complete: Icon(Icons.check, color: Colors.blue[400]),
            waterDropColor: Color.fromARGB(255, 66, 165, 245),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Posibles Ligues",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                              SizedBox(
                                width: 10,
                              )
                            ] +
                            _listCardLigues(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "99+ likes",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Messages",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ] +
                  _listViewUsuarios(),
            ),
          ),
        ));
  }

  List<Widget> _listCardLigues() {
    List<Widget> list = [CardChatEspecial()];
    for (var user in posiblesLigues) {
      list.add(CardChat());
    }
    return list;
  }

  List<Widget> _listViewUsuarios() {
    List<Widget> list = [];
    for (var user in usuarios) {
      list.add(ListtitleWidget(
        usuario: user,
      ));
      list.add(Divider(
        indent: 120,
      ));
    }
    if (list.isNotEmpty) {
      list.removeLast();
    }
    return list;
  }

  _cargarUsuarios() async {
    this.usuarios = await usuarioService.getUsuarios();
    for (var usuario in usuarios) {
      usuario.last_message = HiveService().getLastMessagesForUser(usuario.uid);
    }
    setState(() {});

    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
