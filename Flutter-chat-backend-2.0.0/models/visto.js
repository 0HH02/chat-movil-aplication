const { DataTypes } = require('sequelize');
const { sequelize } = require('../database/config');
const Usuario = require('./usuario');

const Seen = sequelize.define('seen', {
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
    tableName: 'seen',
    toJSON: {
        transform: (doc, ret) => {
            const { id, ...rest } = ret;
            return rest;
        }
    }
});

// Definir las relaciones
Usuario.hasMany(Seen, { foreignKey: 'de' });
Usuario.hasMany(Seen, { foreignKey: 'para' });
Seen.belongsTo(Usuario, { foreignKey: 'de' });
Seen.belongsTo(Usuario, { foreignKey: 'para' });

module.exports = Seen;
