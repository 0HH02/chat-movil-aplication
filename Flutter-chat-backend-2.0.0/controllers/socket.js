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

module.exports = {
    usuarioConectado,
    usuarioDesconectado,
    grabarMensaje
};
