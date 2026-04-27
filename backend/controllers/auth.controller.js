const db = require('../models');
const User = db.User;
const Couple = db.Couple;
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

exports.register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Şifreyi hashle
    const hashedPassword = await bcrypt.hash(password, 10);

    // Kullanıcıyı oluştur
    const user = await User.create({
      username,
      email,
      password: hashedPassword
    });

    res.status(201).send({ message: "Kullanıcı başarıyla kaydedildi!" });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).send({ message: "Kullanıcı bulunamadı." });
    }

    const passwordIsValid = await bcrypt.compare(password, user.password);
    if (!passwordIsValid) {
      return res.status(401).send({ message: "Geçersiz şifre!" });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'secret-key', {
      expiresIn: 86400 // 24 saat
    });

    res.status(200).send({
      id: user.id,
      username: user.username,
      email: user.email,
      coupleId: user.coupleId,
      accessToken: token
    });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.createCouple = async (req, res) => {
  try {
    const userId = req.userId; // Middleware'den gelecek
    const inviteCode = crypto.randomBytes(3).toString('hex').toUpperCase();

    const couple = await Couple.create({ inviteCode });
    await User.update({ coupleId: couple.id }, { where: { id: userId } });

    res.status(201).send({ inviteCode, message: "Çift grubu oluşturuldu!" });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};

exports.joinCouple = async (req, res) => {
  try {
    const { inviteCode } = req.body;
    const userId = req.userId;

    const couple = await Couple.findOne({ where: { inviteCode } });
    if (!couple) {
      return res.status(404).send({ message: "Geçersiz davet kodu." });
    }

    await User.update({ coupleId: couple.id }, { where: { id: userId } });
    res.status(200).send({ message: "Çifte başarıyla katıldınız!" });
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
};
