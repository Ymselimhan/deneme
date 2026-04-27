const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
});

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Modelleri buraya ekleyeceğiz
db.User = require('./User')(sequelize, Sequelize);
db.Couple = require('./Couple')(sequelize, Sequelize);
db.Message = require('./Message')(sequelize, Sequelize);
db.Song = require('./Song')(sequelize, Sequelize);
db.Memory = require('./Memory')(sequelize, Sequelize);

// İlişkiler
db.User.belongsTo(db.Couple, { foreignKey: 'coupleId' });
db.Couple.hasMany(db.User, { foreignKey: 'coupleId' });

db.Message.belongsTo(db.Couple, { foreignKey: 'coupleId' });
db.Couple.hasMany(db.Message, { foreignKey: 'coupleId' });
db.Message.belongsTo(db.User, { foreignKey: 'senderId', as: 'sender' });

db.Song.belongsTo(db.Couple, { foreignKey: 'coupleId' });
db.Couple.hasMany(db.Song, { foreignKey: 'coupleId' });

db.Memory.belongsTo(db.Couple, { foreignKey: 'coupleId' });
db.Couple.hasMany(db.Memory, { foreignKey: 'coupleId' });

module.exports = db;
