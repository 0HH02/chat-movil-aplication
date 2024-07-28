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
    },
    isAudio: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
      },
    audioData: {
        type: DataTypes.BLOB,
        allowNull: true,
    },
}, {
    timestamps: true,
    toJSON: {
        transform: (doc, ret) => {
            const { id, ...rest } = ret;
            return rest;
        }
    }
});

module.exports = Mensaje;
