const authJwt = require("../middleware/authJwt");
const controller = require("../controllers/memory.controller");
const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "public/uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

module.exports = function(app) {
  app.post(
    "/api/memories/add",
    [authJwt.verifyToken, upload.single("image")],
    controller.addMemory
  );
  
  app.get(
    "/api/memories/:coupleId",
    [authJwt.verifyToken],
    controller.getMemories
  );

  app.delete(
    "/api/memories/:id",
    [authJwt.verifyToken],
    controller.deleteMemory
  );
};
