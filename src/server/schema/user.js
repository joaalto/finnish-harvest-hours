const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: Number,
    previousBalance: Number
});

module.exports = mongoose.model('User', userSchema);
