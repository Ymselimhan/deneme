const authJwt = require("../middleware/authJwt");
const controller = require("../controllers/chat.controller");

module.exports = function(app) {
  app.get(
    "/api/chat/history/:coupleId",
    [authJwt.verifyToken],
    controller.getChatHistory
  );
};
