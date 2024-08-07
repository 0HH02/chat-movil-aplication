const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/config');
const Usuario = require('./usuario');

const Mensaje = sequelize.define('mensaje', {
    de: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Usuario,
            key: 'id'
        }
    },
    para: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Usuario,
            key: 'id'
        }
    },
    mensaje: {
        type: DataTypes.STRING,
        allowNull: false
    }, 
    mid: {
        type: DataTypes.STRING,
        allowNull: false,
        primaryKey: true
    },
    rid: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    mediaType: {
        type: DataTypes.STRING,
        allowNull: false
    }, 
    multimedia: {
        type: DataTypes.BLOB,
        allowNull: true,
    },
    date: {
        type: DataTypes.STRING,
        allowNull: false,
        
    },
}, {
    timestamps: false
});

module.exports = Mensaje;
