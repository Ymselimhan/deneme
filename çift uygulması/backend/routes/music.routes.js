const authJwt = require("../middleware/authJwt");
const controller = require("../controllers/music.controller");

module.exports = function(app) {
  app.post("/api/music/add", [authJwt.verifyToken], controller.addSong);
  app.get("/api/music/:coupleId", [authJwt.verifyToken], controller.getSongs);
  app.delete("/api/music/:id", [authJwt.verifyToken], controller.deleteSong);
};
