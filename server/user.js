const User = require('./schema/user');

function upsertUserBalance(id, balance) {
  upsertUser(id, { previousBalance: balance });
}

function upsertUserVariantPeriods(id, variantPeriods) {
  upsertUser(id, { variantPeriods });
}

function upsertUser(id, data) {
  User.findOneAndUpdate(
    { id: id },
    data,
    { new: true, upsert: true },
    (err, doc) => {
      if (err) {
        console.error(err);
      }
    }
  );
}

module.exports = {
  upsertUserBalance: upsertUserBalance,
  upsertUserVariantPeriods: upsertUserVariantPeriods
};