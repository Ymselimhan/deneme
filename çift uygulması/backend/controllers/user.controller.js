const db = require("../models");
const User = db.User;

exports.getPartnerLocation = async (req, res) => {
  try {
    const { coupleId } = req.params;
    const currentUserId = req.userId;

    // Partneri bul (aynı odada olan ama ben olmayan kullanıcı)
    const partner = await User.findOne({
      where: {
        coupleId: coupleId,
        id: { [db.Sequelize.Op.ne]: currentUserId }
      },
      attributes: ['id', 'username', 'lastLat', 'lastLng', 'updatedAt']
    });

    if (!partner) {
      return res.status(404).send({ message: "Partner bulunamadı." });
    }

    res.status(200).send(partner);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
