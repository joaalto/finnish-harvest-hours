const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: {
        first: String,
        last: String
    },
    accessToken: String
});

module.exports = mongoose.model('User', userSchema);