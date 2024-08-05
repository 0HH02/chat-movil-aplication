const { io } = require('../index');
const { comprobarJWT } = require('../helpers/jwt');
const { usuarioConectado, usuarioDesconectado, grabarMensaje, borrarMensaje, obtenerMensajesPendientes, seenMessage, obtenerVistosPendientes, borrarVisto } = require('../controllers/socket');

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
            rid: mensaje.rid,
            mediaType: mensaje.mediaType,
            multimedia: mensaje.multimedia,
            date: mensaje.date
        });
        console.log('emited: ', mensaje.mensaje)
    });
    const vistosPendientes = await obtenerVistosPendientes(uid);
    vistosPendientes.forEach(mensaje => {
        io.to( Number(mensaje.para) ).emit('confirmar-visto', {
            de: mensaje.de,
            para: mensaje.para,
            mid: mensaje.mid,
        });
        console.log('emited: ', mensaje.mid)
    });


    // Escuchar del cliente el mensaje-personal
    client.on('mensaje-personal', async( payload ) => {
        console.log('Mensaje recibido:', payload);
        await grabarMensaje( payload );
        io.to( Number(payload.para) ).emit('mensaje-personal', payload );
    })

    client.on('confirmar-recepcion', async(payload) => {
        console.log(`Confirmación de recepción del mensaje ${payload['mid']} por el usuario ${payload['para']}`);
        // Borrar el mensaje de la base de datos
        await seenMessage(payload)
        io.to( Number(payload.
            de
        ) ).emit('confirmar-visto', payload );
        await borrarMensaje(payload['mid']);
    });

    client.on('confirmar-visto', async(payload) => {
        console.log(`Confirmación de recepción del visto ${payload['mid']} por el usuario ${payload['para']}`);
        await borrarVisto(payload['mid']);

    })

    client.on('disconnect', () => {
        usuarioDesconectado(uid);
    });

});
