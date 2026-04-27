const db = require("../models");
const Song = db.Song;

exports.addSong = async (req, res) => {
  try {
    const { title, artist, url, coupleId } = req.body;
    const song = await Song.create({
      title,
      artist,
      url,
      coupleId,
      addedBy: req.userId
    });
    res.status(201).send(song);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.getSongs = async (req, res) => {
  try {
    const { coupleId } = req.params;
    const songs = await Song.findAll({
      where: { coupleId },
      order: [['createdAt', 'DESC']]
    });
    res.status(200).send(songs);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.deleteSong = async (req, res) => {
  try {
    const { id } = req.params;
    await Song.destroy({ where: { id } });
    res.status(200).send({ message: "Şarkı silindi." });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
