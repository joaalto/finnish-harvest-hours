const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: Number,
    firstName: String,
    lastName: String,
    accessToken: String
});

module.exports = mongoose.model('User', userSchema);