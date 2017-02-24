const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({

    session: {
        cookie: {
            originalMaxAge: Number,
            expires: Date,
            secure: Boolean,
            httpOnly: Boolean,
            domain: String,
            path: String,
            sameSite: Boolean
        },
        passport: {
            user: {
                harvestId: Number,
                firstName: String,
                lastName: String,
                accessToken: String,
                refreshToken: String
            }
        }
    },
    expires: Date
})

module.exports = mongoose.model('Session', sessionSchema);
