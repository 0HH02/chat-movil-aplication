const { Sequelize } = require('sequelize');
const config = require('../config/config.json');

const sequelize = new Sequelize(
    config.development.database,
    config.development.username,
    config.development.password,
    {
      host: config.development.host,
      dialect: config.development.dialect,
      logging: config.development.logging
    }
  );

const dbConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('DB Online');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        throw new Error('Error en la base de datos - Hable con el admin');
    }
};

module.exports = {
    dbConnection,
    sequelize
};
