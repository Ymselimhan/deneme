module.exports = (sequelize, Sequelize) => {
  const Memory = sequelize.define('memory', {
    title: {
      type: Sequelize.STRING,
      allowNull: true
    },
    imageUrl: {
      type: Sequelize.STRING,
      allowNull: false
    },
    coupleId: {
      type: Sequelize.INTEGER,
      allowNull: false
    },
    addedBy: {
      type: Sequelize.INTEGER,
      allowNull: false
    }
  });

  return Memory;
};
