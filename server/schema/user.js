const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: Number,
    previousBalance: Number,
    variantPeriods: [{
        start: Date, // Front-end expects this to exist.
        end: Date, // This can be null, however. A null value indicates 'indefinitely'.
        dailyHours: Number
    }]
});

module.exports = mongoose.model('User', userSchema);
