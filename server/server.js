const express = require('express');
const request = require('superagent');
const bodyParser = require('body-parser');
const passport = require('passport');
const OAuth2Strategy = require('passport-oauth2');
const session = require('express-session');
const MongoStore = require('connect-mongo')(session);
const mongoose = require('mongoose');
const _ = require('lodash');
const Api = require('./api');
const User = require('./schema/user');

const mongoUrl =
    process.env.MONGOLAB_URI ||
    'mongodb://localhost/saldot';


const app = express()

mongoose.connect(mongoUrl);

app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
    store: new MongoStore({
        url: mongoUrl
    })
}));

const forceSsl = function(req, res, next) {
    if (req.headers['x-forwarded-proto'] !== 'https') {
        return res.redirect(['https://', req.get('Host'), req.url].join(''));
    }
    return next();
};

app.use(bodyParser.json());
app.use(passport.initialize());
app.use(passport.session());
app.use(forceSsl);

passport.serializeUser(function(user, done) {
    done(null, user);
});

passport.deserializeUser(function(user, done) {
    done(null, user);
});

passport.use(
    'oauth2',
    new OAuth2Strategy({
            authorizationURL: `${Api.harvestUrl}/oauth2/authorize`,
            tokenURL: `${Api.harvestUrl}/oauth2/token`,
            clientID: process.env.CLIENT_ID,
            clientSecret: process.env.CLIENT_SECRET,
            callbackURL: process.env.CALLBACK_URL
        },
        // TODO: handle refresh tokens
        function(accessToken, refreshToken, profile, done) {
            request
                .get(`${Api.harvestUrl}/account/who_am_i`)
                .type('json')
                .accept('json')
                .query({
                    access_token: accessToken
                })
                .end((err, res) => {
                    const harvestUser = res.body.user;
                    const user = {
                        id: harvestUser.id,
                        firstName: harvestUser.first_name,
                        lastName: harvestUser.last_name,
                        accessToken: accessToken
                    };
                    done(err, user);
                });
        }
    ));

function ensureAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    } else {
        res.redirect('/login');
    }
}

app.get('/login', passport.authenticate('oauth2'));

app.get(
    '/auth/callback',
    passport.authenticate('oauth2', {
        failureRedirect: '/error',
        successRedirect: '/'
    }));

app.all('*', ensureAuthenticated);

app.use('/', express.static(__dirname + '/static'));

app.get('/user', function(req, res) {
    if (req.isAuthenticated()) {
        const sessionUser = req.session.passport.user;
        User.findOne(
            { id: sessionUser.id },
            (err, doc) => {
                if(err) {
                    console.error(err);
                }

                let previousBalance = 0;
                if(doc && doc.previousBalance) {
                    previousBalance = doc.previousBalance;
                }

                res.send({
                    firstName: sessionUser.firstName,
                    lastName: sessionUser.lastName,
                    previousBalance: previousBalance
                });
            }
        );
    }
});

app.get('/holidays', function(req, res) {
    const options = {
        root: __dirname + '/static'
    };
    res.sendFile('finnish_holidays_2016.json', options);
});

app.get('/entries', function(req, res) {
    Api.fetchHourEntries(req, res)
        .then(entries => res.send(entries));
});

app.post('/balance', function(req, res) {
    if (req.isAuthenticated()) {
        const sessionUser = req.session.passport.user;
        upsertUser(sessionUser.id, req.body.balance);
    }
    res.send('OK');
});

const upsertUser = (id, balance) => {
    User.findOneAndUpdate(
        { id: id },
        { previousBalance: balance },
        { new: true, upsert: true },
        (err, doc) => {
            if(err) {
                console.error(err);
            }
        }
    );
}

const port = process.env.PORT || 8080;
app.listen(port);
console.log('Server listening in port: ' + port);

process.on('uncaughtException', function(error) {
    console.log(error.stack);
});
