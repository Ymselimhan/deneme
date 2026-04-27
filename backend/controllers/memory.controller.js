const db = require("../models");
const Memory = db.Memory;

exports.addMemory = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send({ message: "Fotoğraf yüklenemedi." });
    }

    const { title, coupleId } = req.body;
    const imageUrl = `/uploads/${req.file.filename}`;

    const memory = await Memory.create({
      title,
      imageUrl,
      coupleId,
      addedBy: req.userId
    });

    res.status(201).send(memory);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.getMemories = async (req, res) => {
  try {
    const { coupleId } = req.params;
    const memories = await Memory.findAll({
      where: { coupleId },
      order: [['createdAt', 'DESC']]
    });
    res.status(200).send(memories);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.deleteMemory = async (req, res) => {
  try {
    const { id } = req.params;
    await Memory.destroy({ where: { id } });
    res.status(200).send({ message: "Anı silindi." });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
