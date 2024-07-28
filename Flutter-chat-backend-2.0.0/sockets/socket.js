const { io } = require('../index');
const { comprobarJWT } = require('../helpers/jwt');
const { usuarioConectado, usuarioDesconectado, grabarMensaje, borrarMensaje, obtenerMensajesPendientes } = require('../controllers/socket');

// Mensajes de Sockets
io.on('connection', async (client) =>  {
    const [ valido, uid ] = comprobarJWT( client.handshake.headers['x-token'] )
    // Verificar autenticación
    if ( !valido ) { return client.disconnect(); }
    
    // Cliente autenticado
    usuarioConectado( uid );
    
    // Ingresar al usuario a una sala en particular
    // sala global, client.id, 5f298534ad4169714548b785
    client.join( uid );
    console.log("user join", uid)

    const mensajesPendientes = await obtenerMensajesPendientes(uid);
    mensajesPendientes.forEach(mensaje => {
        io.to( Number(mensaje.para) ).emit('mensaje-personal', {
            de: mensaje.de,
            para: mensaje.para,
            mensaje: mensaje.mensaje,
            mid: mensaje.mid,
            isAudio: mensaje.isAudio,
            audioData: mensaje.audioData,
        });
        console.log('emited: ', mensaje.mensaje)
    });


    // Escuchar del cliente el mensaje-personal
    client.on('mensaje-personal', async( payload ) => {
        // TODO: Grabar mensaje
        console.log('Mensaje recibido:', payload);
        await grabarMensaje( payload );
        io.to( Number(payload.para) ).emit('mensaje-personal', payload );
    })

    client.on('confirmar-recepcion', async({ mensajeId, para }) => {
        console.log(`Confirmación de recepción del mensaje ${mensajeId} por el usuario ${para}`);
        // Borrar el mensaje de la base de datos
        await borrarMensaje(mensajeId);
    });

    client.on('disconnect', () => {
        usuarioDesconectado(uid);
    });

});
