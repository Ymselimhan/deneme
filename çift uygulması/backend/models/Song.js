module.exports = (sequelize, Sequelize) => {
  const Song = sequelize.define('song', {
    title: {
      type: Sequelize.STRING,
      allowNull: false
    },
    artist: {
      type: Sequelize.STRING,
      allowNull: true
    },
    url: {
      type: Sequelize.STRING,
      allowNull: true // Spotify/Youtube linki
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

  return Song;
};
