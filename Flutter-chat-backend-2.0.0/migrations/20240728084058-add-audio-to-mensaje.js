'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('mensajes', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,
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
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
      mid: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      isAudio: {
        allowNull: false,
        type: Sequelize.BOOLEAN,
      },
      audioData: {
        allowNull: true,
        type: Sequelize.BLOB,
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('mensajes');
  },
};
