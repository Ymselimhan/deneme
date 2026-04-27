const db = require("../models");
const Message = db.Message;

exports.getChatHistory = async (req, res) => {
  try {
    const { coupleId } = req.params;
    
    const messages = await Message.findAll({
      where: { coupleId },
      order: [['createdAt', 'ASC']],
      include: ['sender']
    });

    res.status(200).send(messages);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
