const authJwt = require("../middleware/authJwt");
const controller = require("../controllers/auth.controller");

module.exports = function(app) {
  app.use(function(req, res, next) {
    res.header(
      "Access-Control-Allow-Headers",
      "x-access-token, Origin, Content-Type, Accept"
    );
    next();
  });

  app.post("/api/auth/register", controller.register);
  app.post("/api/auth/login", controller.login);
  
  // Çift işlemleri (Giriş yapmış kullanıcı gerekir)
  app.post("/api/couple/create", [authJwt.verifyToken], controller.createCouple);
  app.post("/api/couple/join", [authJwt.verifyToken], controller.joinCouple);
};
