const db = require("../models");
const SpecialDate = db.SpecialDate;

exports.createDate = async (req, res) => {
  try {
    const { title, date, type, description, coupleId } = req.body;
    const specialDate = await SpecialDate.create({
      title,
      date,
      type,
      description,
      coupleId
    });
    res.status(201).send(specialDate);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.getDates = async (req, res) => {
  try {
    const { coupleId } = req.params;
    const dates = await SpecialDate.findAll({
      where: { coupleId },
      order: [['date', 'ASC']]
    });
    res.status(200).send(dates);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.deleteDate = async (req, res) => {
  try {
    const { id } = req.params;
    await SpecialDate.destroy({ where: { id } });
    res.status(200).send({ message: "Özel gün silindi." });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
