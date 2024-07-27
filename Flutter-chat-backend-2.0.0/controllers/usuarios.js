const { response } = require('express');
const { Op } = require('sequelize');``
const Usuario = require('../models/usuario');

const getUsuarios = async (req, res = response) => {
    const desde = Number(req.query.desde) || 0;

    const usuarios = await Usuario.findAll({
        where: { id: { [Op.ne]: req.uid } },
        order: [['online', 'DESC']],
        offset: desde,
        limit: 20
    });

    res.json({
        ok: true,
        usuarios,
    });
};

module.exports = {
    getUsuarios
};
