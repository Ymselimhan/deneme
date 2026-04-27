module.exports = (sequelize, Sequelize) => {
  const Couple = sequelize.define('couple', {
    name: {
      type: Sequelize.STRING,
      allowNull: true // İsteğe bağlı, örneğin "Caner & Selin"
    },
    anniversaryDate: {
      type: Sequelize.DATE,
      allowNull: true
    },
    inviteCode: {
      type: Sequelize.STRING,
      unique: true,
      allowNull: false
    }
  });

  return Couple;
};
