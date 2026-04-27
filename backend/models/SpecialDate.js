module.exports = (sequelize, Sequelize) => {
  const SpecialDate = sequelize.define('specialDate', {
    title: {
      type: Sequelize.STRING,
      allowNull: false
    },
    date: {
      type: Sequelize.DATE,
      allowNull: false
    },
    type: {
      type: Sequelize.ENUM('anniversary', 'birthday', 'other', 'custom'),
      defaultValue: 'other'
    },
    description: {
      type: Sequelize.TEXT,
      allowNull: true
    }
  });

  return SpecialDate;
};
