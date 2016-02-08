const express = require('express');
const request = require('superagent');
const jsonParser = require('body-parser').json();
const passport = require('passport');
const OAuth2Strategy = require('passport-oauth2');
const mongoose = require('mongoose');
const User = require('./model/user');

const uriString =
    process.env.MONGOLAB_URI ||
    'mongodb://localhost/saldot';

mongoose.connect(uriString, (err, res) => {
    if (err) {
        console.log('ERROR connecting to: ' + uriString + '. ' + err);
    } else {
        console.log('Connected to: ' + uriString);
    }
});

const app = express()

app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser(function(user, done) {
    // console.log('user: ', user);
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
            callbackURL: 'https://saldot.herokuapp.com/auth/callback'
        },
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
                    // findOrCreateUser(user, err);
                    // done(null, user);

                    User.findOne({
                        id: user.id
                    }, function(err, dbUser) {
                        if (err) {
                            console.log(err);
                        } else if (dbUser === null) {
                            // var u = new User(user);
                            var usr = new User({
                                id: harvestUser.id
                            });

                            usr.save(err) => {
                                if (err) {
                                    console.log(err)
                                }
                            };
                        }
                        done(err, user);
                    });
                });
        }
    ));

const findOrCreateUser = function(user) {}

app.get('/login', passport.authenticate('oauth2'));

app.get(
    '/auth/callback',
    passport.authenticate('oauth2', {
        failureRedirect: '/error'
    }),
    function(req, res) {
        res.end(`${req.user.firstName} ${req.user.lastName} logged in.`);
    });

app.use('/', express.static(__dirname + '/dist'));

const port = process.env.PORT || 8080;
app.listen(port);
console.log('Server listening in port: ' + port);