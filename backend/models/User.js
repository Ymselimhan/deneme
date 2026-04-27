module.exports = (sequelize, Sequelize) => {
  const User = sequelize.define('user', {
    username: {
      type: Sequelize.STRING,
      allowNull: false,
      unique: true
    },
    email: {
      type: Sequelize.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: Sequelize.STRING,
      allowNull: false
    },
    coupleId: {
      type: Sequelize.INTEGER,
      allowNull: true
    },
    lastLat: {
      type: Sequelize.DOUBLE,
      allowNull: true
    },
    lastLng: {
      type: Sequelize.DOUBLE,
      allowNull: true
    }
  });

  return User;
};
