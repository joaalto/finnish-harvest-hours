const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: Number,
    previousBalance: Number,
    variantPeriods: [{
        start: Date,
        end: Date,
        dailyHours: Number
    }]
});

module.exports = mongoose.model('User', userSchema);
