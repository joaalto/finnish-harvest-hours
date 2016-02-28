const express = require('express');
const request = require('superagent');
const jsonParser = require('body-parser').json();
const passport = require('passport');
const OAuth2Strategy = require('passport-oauth2');
const session = require('express-session');
const MongoStore = require('connect-mongo')(session);
const _ = require('lodash');
const Api = require('./js/api');

const mongoUrl =
    process.env.MONGOLAB_URI ||
    'mongodb://localhost/saldot';

const app = express()

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
            authorizationURL: 'https://wunderdog.harvestapp.com/oauth2/authorize',
            tokenURL: 'https://wunderdog.harvestapp.com/oauth2/token',
            clientID: process.env.CLIENT_ID,
            clientSecret: process.env.CLIENT_SECRET,
            callbackURL: process.env.CALLBACK_URL || 'https://saldot.herokuapp.com/auth/callback'
        },
        // TODO: handle refresth tokens
        function(accessToken, refreshToken, profile, done) {
            request
                .get('https://wunderdog.harvestapp.com/account/who_am_i')
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

app.use('/', express.static(__dirname + '/dist'));

app.get('/user', function(req, res) {
    if (req.isAuthenticated()) {
        const user = req.session.passport.user;
        res.send(_.pick(user, 'firstName', 'lastName'));
    }
});

app.get('/entries', function(req, res) {
    Api.fetchHourEntries(req, res)
        .then(entries => res.send(entries));
});

const port = process.env.PORT || 8080;
app.listen(port);
console.log('Server listening in port: ' + port);

process.on('uncaughtException', function(error) {
    console.log(error.stack);
});