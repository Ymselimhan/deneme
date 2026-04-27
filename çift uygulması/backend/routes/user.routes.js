const authJwt = require("../middleware/authJwt");
const controller = require("../controllers/user.controller");

module.exports = function(app) {
  app.get(
    "/api/user/partner-location/:coupleId",
    [authJwt.verifyToken],
    controller.getPartnerLocation
  );
};
