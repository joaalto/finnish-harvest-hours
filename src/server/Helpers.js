
exports.getUserImpl = function (req) {
  return function () {
    return req.session.passport.user;
  }
}