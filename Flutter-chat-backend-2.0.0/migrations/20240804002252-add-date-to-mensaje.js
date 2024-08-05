'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('mensajes', {
      mid: {
        allowNull: false,
        type: Sequelize.STRING,
        primaryKey: true,
      },
      de: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'usuarios',
          key: 'id',
        },
      },
      para: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'usuarios',
          key: 'id',
        },
      },
      mensaje: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      mediaType: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      multimedia: {
        allowNull: true,
        type: Sequelize.BLOB,
      },
      rid: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      date: {
        type: Sequelize.STRING,
        allowNull: false,
      },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('mensajes');
  },
};