const Usuario = require('../models/usuario');
const Mensaje = require('../models/mensaje');

const usuarioConectado = async (uid = '') => {
    const usuario = await Usuario.findByPk(uid);
    if (usuario) {
        usuario.online = true;
        await usuario.save();
    }
    return usuario;
}

const usuarioDesconectado = async (uid = '') => {
    const usuario = await Usuario.findByPk(uid);
    if (usuario) {
        usuario.online = false;
        await usuario.save();
    }
    return usuario;
}


const grabarMensaje = async (payload) => {
    try {
        await Mensaje.create(payload);
        return true;
    } catch (error) {
        return false;
    }
}

const borrarMensaje = async (mensajeId) => {
    try {
        const result = await Mensaje.destroy({where:{mid: mensajeId}});
        return !!(result);
    } catch (error) {
        console.log(error);
        return false;
    }
}

const obtenerMensajesPendientes = async (userId) => {
    try {
        const mensajes = await Mensaje.findAll({
            where: {
                para: userId
            }
        });
        return mensajes;
    } catch (error) {
        console.error('Error al obtener mensajes pendientes:', error);
        return [];
    }
};





module.exports = {
    usuarioConectado,
    usuarioDesconectado,
    grabarMensaje,
    borrarMensaje,
    obtenerMensajesPendientes
};
