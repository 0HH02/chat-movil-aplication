const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/config');

const Usuario = sequelize.define('usuario', {
    nombre: {
        type: DataTypes.STRING,
        allowNull: false
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    online: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    toJSON: {
        transform: (doc, ret) => {
            const { id, password, ...rest } = ret;
            ret.uid = id;
            return rest;
        }
    }
});

module.exports = Usuario;
