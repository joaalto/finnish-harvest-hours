'use strict';

var express = require('express');
var request = require('superagent');
var bodyParser = require('body-parser');
var passport = require('passport');
var OAuth2Strategy = require('passport-oauth2');
var session = require('express-session');
var MongoStore = require('connect-mongo')(session);
var mongoose = require('mongoose');
var _ = require('lodash');
var api = require('./api');
var User = require('./schema/user');
var vars = require('./consts')

exports.isAuthenticatedImpl = function(req) {
    return function() {
      return req.isAuthenticated();
    }
  };

exports.realMain = function (attachFn) {
    return function () {
        var app = express()

        mongoose.connect(vars.mongoUrl);

        app.use(session({
            secret: process.env.SESSION_SECRET,
            resave: false,
            saveUninitialized: true,
            // cookie: { secure: true },
            store: new MongoStore({
                url: vars.mongoUrl,
                stringify: false
            })
        }));

        var forceSsl = function (req, res, next) {
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

        var oauthStrategy = new OAuth2Strategy({
            authorizationURL: vars.harvestUrl + '/oauth2/authorize',
            tokenURL: vars.harvestUrl + '/oauth2/token',
            clientID: process.env.CLIENT_ID,
            clientSecret: process.env.CLIENT_SECRET,
            callbackURL: process.env.CALLBACK_URL
        },
            function (accessToken, refreshToken, profile, done) {
                request
                    .get(vars.harvestUrl + '/account/who_am_i')
                    .type('json')
                    .accept('json')
                    .query({
                        access_token: accessToken
                    })
                    .end(function(err, res) {
                        var harvestUser = res.body.user;
                        var user = {
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

        // app.all('*', ensureAuthenticated);

        app.use('/', express.static(__dirname + '/static'));

        app.get('/user', function (req, res) {
            if (req.isAuthenticated()) {
                var sessionUser = req.session.passport.user;
                User.findOne(
                    { id: sessionUser.harvestId },
                    function(err, doc) {
                        if (err) {
                            console.error(err);
                        }

                        var previousBalance = 0;
                        if (doc && doc.previousBalance) {
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

        app.get('/holidays', function (req, res) {
            var options = {
                root: __dirname + '/static'
            };
            res.sendFile('finnish_holidays.json', options);
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
                    .map(function(taskId) {
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
                var sessionUser = req.session.passport.user;
                upsertUser(sessionUser.harvestId, req.body.balance);
            }
            res.send('OK');
        });

        var upsertUser = function(id, balance) {
            User.findOneAndUpdate(
                { id: id },
                { previousBalance: balance },
                { new: true, upsert: true },
                function(err, doc) {
                    if (err) {
                        console.error(err);
                    }
                }
            );
        }

        var port = process.env.PORT || 8080;
        attachFn(app)();
        app.listen(port);
        console.log('Server listening in port: ' + port);

        process.on('uncaughtException', function (error) {
            console.log(error.stack);
        });

    }
}
