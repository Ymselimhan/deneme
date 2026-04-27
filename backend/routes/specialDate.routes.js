const { authJwt } = require("../middleware");
const controller = require("../controllers/specialDate.controller");

module.exports = function(app) {
  app.use(function(req, res, next) {
    res.header(
      "Access-Control-Allow-Headers",
      "x-access-token, Origin, Content-Type, Accept"
    );
    next();
  });

  app.post(
    "/api/dates",
    [authJwt.verifyToken],
    controller.createDate
  );

  app.get(
    "/api/dates/:coupleId",
    [authJwt.verifyToken],
    controller.getDates
  );

  app.delete(
    "/api/dates/:id",
    [authJwt.verifyToken],
    controller.deleteDate
  );
};
