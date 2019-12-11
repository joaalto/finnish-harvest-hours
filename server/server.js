'use strict';

const express = require('express');
const request = require('superagent');
const bodyParser = require('body-parser');
const passport = require('passport');
const OAuth2Strategy = require('passport-oauth2');
const session = require('express-session');
const MongoStore = require('connect-mongo')(session);
const mongoose = require('mongoose');
const _ = require('lodash');
const api = require('./api');
const consts = require('./consts');
const userService = require('./user');
const User = require('./schema/user');

const app = express()

mongoose.connect(consts.mongoUrl);

app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
    // cookie: { secure: true },
    store: new MongoStore({
        url: consts.mongoUrl,
        stringify: false
    })
}));

const forceSsl = function (req, res, next) {
    if (req.headers['x-forwarded-proto'] !== 'https') {
        return res.redirect(['https://', req.get('Host'), req.url].join(''));
    }
    return next();
};

app.use(bodyParser.json());
app.use(passport.initialize());
app.use(passport.session());
app.use(forceSsl);

passport.serializeUser(function (user, done) {
    done(null, user);
});

passport.deserializeUser(function (user, done) {
    done(null, user);
});

const oauthStrategy = new OAuth2Strategy({
        authorizationURL: `${consts.harvestUrl}/oauth2/authorize`,
        tokenURL: `${consts.harvestUrl}/oauth2/token`,
        clientID: process.env.CLIENT_ID,
        clientSecret: process.env.CLIENT_SECRET,
        callbackURL: process.env.CALLBACK_URL
    },
    function (accessToken, refreshToken, profile, done) {
        request
            .get(`${consts.harvestUrl}/account/who_am_i`)
            .type('json')
            .accept('json')
            .query({
                access_token: accessToken
            })
            .end((err, res) => {
                const harvestUser = res.body.user;
                const user = {
                    harvestId: harvestUser.id,
                    firstName: harvestUser.first_name,
                    lastName: harvestUser.last_name,
                    accessToken: accessToken,
                    refreshToken: refreshToken
                };
                done(err, user);
            });
    }
);

passport.use('oauth2', oauthStrategy);

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

app.get('/user', function (req, res) {
    if (req.isAuthenticated()) {
        const sessionUser = req.session.passport.user;
        User.findOne(
            { id: sessionUser.harvestId },
            (err, doc) => {
                if (err) {
                    console.error(err);
                }

                const previousBalance = doc && doc.previousBalance ? doc.previousBalance : 0;
                const variantPeriods = doc && doc.variantPeriods ? doc.variantPeriods : [];

                res.send({
                    firstName: sessionUser.firstName,
                    lastName: sessionUser.lastName,
                    previousBalance: previousBalance,
                    variantPeriods: variantPeriods
                });
            }
        );
    }
});

app.get('/holidays', function (req, res) {
    res.send(api.finnishHolidays())
});

app.get('/entries', function (req, res) {
    api.fetchHourEntries(req, res)
});

function idStringToTasks(taskIds) {
    if (!taskIds) {
        return []
    } else {
        return taskIds
            .split(',')
            .map(taskId => {
                return { taskId: parseInt(taskId) }
            })
    }
}

app.get('/special_tasks', function (req, res) {
    res.send({
        ignore: idStringToTasks(process.env.IGNORE_TASK_IDS),
        kiky: idStringToTasks(process.env.KIKY_TASK_IDS)
    });
});

app.post('/balance', function (req, res) {
    if (req.isAuthenticated()) {
        const sessionUser = req.session.passport.user;
        userService.upsertUserBalance(sessionUser.harvestId, req.body.balance);
    }
    res.send('OK');
});

app.post('/variant-periods', function (req, res) {
  if (req.isAuthenticated()) {
    const sessionUser = req.session.passport.user;
    userService.upsertUserVariantPeriods(sessionUser.harvestId, req.body.variantPeriods);
  }
  res.send('OK');
});


const port = process.env.PORT || 8080;
app.listen(port);
console.log('Server listening in port: ' + port);

process.on('uncaughtException', function (error) {
    console.log(error.stack);
});
