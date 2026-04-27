module.exports = (sequelize, Sequelize) => {
  const Message = sequelize.define('message', {
    text: {
      type: Sequelize.TEXT,
      allowNull: false
    },
    senderId: {
      type: Sequelize.INTEGER,
      allowNull: false
    },
    coupleId: {
      type: Sequelize.INTEGER,
      allowNull: false
    }
  });

  return Message;
};
