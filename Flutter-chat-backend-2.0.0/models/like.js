const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/config');
const Usuario = require('./usuario');

const LikeMessage = sequelize.define('likeMessage', {
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
    mid: {
        type: DataTypes.STRING,
        allowNull: false,
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

module.exports = LikeMessage;
