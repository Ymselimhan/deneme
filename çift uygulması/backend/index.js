const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();

// Sistem Günlüğü Yakalama
const originalLog = console.log;
const originalError = console.error;
const originalWarn = console.warn;

const captureLog = (type, args) => {
  const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : arg).join(' ');
  const logEntry = {
    type,
    message,
    timestamp: new Date().toLocaleTimeString(),
  };
  
  if (type === 'log') originalLog(...args);
  else if (type === 'error') originalError(...args);
  else if (type === 'warn') originalWarn(...args);
  
  if (global.io) {
    global.io.emit('system_log', logEntry);
  }
};

console.log = (...args) => captureLog('log', args);
console.error = (...args) => captureLog('error', args);
console.warn = (...args) => captureLog('warn', args);

const db = require("./models");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public')); // Statik dosyaları servis et

// Veritabanı Senkronizasyonu
db.sequelize.sync().then(() => {
  console.log("Veritabanı senkronize edildi.");
});

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});
global.io = io; // Loglar için global'e ekle

const PORT = process.env.PORT || 3456;

const path = require('path');

// Ana sayfa - Web arayüzünü göster
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Rotalar
require('./routes/auth.routes')(app);
require('./routes/chat.routes')(app);
require('./routes/music.routes')(app);
require('./routes/user.routes')(app);
require('./routes/memory.routes')(app);

// Socket.io Mantığı
io.on('connection', (socket) => {
  console.log('Bir kullanıcı bağlandı:', socket.id);

  socket.on('join_room', (room) => {
    socket.join(room);
    console.log(`Kullanıcı ${socket.id} odaya katıldı: ${room}`);
  });

  socket.on('send_message', async (data) => {
    try {
      const { room, message, senderId } = data;
      // Veritabanına kaydet
      const savedMsg = await db.Message.create({
        text: message,
        senderId: senderId,
        coupleId: room
      });
      // Odaya geri gönder
      io.to(room).emit('receive_message', savedMsg);
    } catch (err) {
      console.error("Mesaj kaydedilemedi:", err);
    }
  });

  socket.on('update_location', async (data) => {
    try {
      const { room, lat, lng, senderId } = data;
      // Veritabanında güncelle
      await db.User.update({ lastLat: lat, lastLng: lng }, { where: { id: senderId } });
      // Odaya broadcast et
      io.to(room).emit('location_updated', data);
    } catch (err) {
      console.error("Konum güncellenemedi:", err);
    }
  });

  socket.on('disconnect', () => {
    console.log('Kullanıcı ayrıldı:', socket.id);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Sunucu 0.0.0.0:${PORT} üzerinde (IPv4) çalışıyor.`);
});
