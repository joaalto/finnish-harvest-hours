const _ = require('lodash');
const Promise = this.Promise || require('promise');
const agent = require('superagent-promise')(require('superagent'), Promise);
const db = require('./db')
const Session = require('./schema/session')

const harvestUrl = `https://${process.env.ORGANIZATION}.harvestapp.com`;

function getUser(req) {
    return req.session.passport.user;
};

function refreshAccessToken(req, res) {
    findAccessToken(req, res, fetchNewAccessToken)
}

function findAccessToken(req, res, callback) {
    Session.findOne(
        { 'session.passport.user.harvestId': req.session.passport.user.harvestId },
        (err, result) => {
            callback(req, res, result.session.passport.user)
        })
}

function fetchNewAccessToken(req, res, user) {
    return agent.post(harvestUrl + '/oauth2/token')
        .type('form')
        .accept('json')
        .send({
            client_id: process.env.CLIENT_ID,
            client_secret: process.env.CLIENT_SECRET,
            grant_type: 'refresh_token',
            refresh_token: user.refreshToken,
        })
        .end()
        .then(resp => {
            console.log('>>> token response:\n', resp.body)
            updateAccessToken(user, resp.body)
        })
        .catch(err => {
            if (err.response.status === 401) {
                req.session.destroy();
                res.redirect('/login');
            }
            console.error('error:', err.response);
        });

}

function updateAccessToken(user, tokenResponse) {
    Session.update(
        { 'session.passport.user.harvestId': user.harvestId },
        { 'session.passport.user.accessToken': tokenResponse.access_token },
        (err, raw) => {
            if (err) {
                console.log('Error updating token:', err)
            } else {
                console.log('Mongo response:', raw)
            }
        }
    )
}

function padWithZero(n) {
    return _.padStart(n, 2, '0');
};

function formatDateForHarvest(date) {
    return `${date.getFullYear()}${padWithZero(date.getMonth() + 1)}${padWithZero(date.getDate())}`;
};

const startDate = process.env.START_DATE;
const endDate = formatDateForHarvest(new Date());

module.exports = {

    harvestUrl: harvestUrl,

    get(req, res, url) {
        return agent.get(harvestUrl + url)
            .type('json')
            .accept('json')
            .query({
                access_token: getUser(req).accessToken
            })
            .end()
            .then(resp => resp.body)
            .catch(err => {
                if (err.response.status === 401) {
                    refreshAccessToken(req, res)
                    // req.session.destroy();
                    // res.redirect('/login');
                }
                console.error('error:', err.response);
            });
    },

    fetchHourEntries(req, res) {
        return this.fetchEntries(req, res)
            .then(entries => this.dayEntries(req, res, entries));
    },

    fetchEntries(req, res) {
        return this.get(
            req, res,
            `/people/${getUser(req).harvestId}/entries?from=${startDate}&to=${endDate}`)
            .then(entries => {
                return _.map(entries, row => {
                    return {
                        date: row.day_entry.spent_at,
                        hours: row.day_entry.hours,
                        taskId: row.day_entry.task_id
                    };
                });
            })
            .catch(err => console.error('>>> error:', err));
    },

    dayEntries(req, res, entries) {
        return _(entries)
            .groupBy('date')
            .mapValues(dayEntries => {
                return {
                    date: dayEntries[0].date,
                    entries: dayEntries.map(entry => {
                        return {
                            hours: entry.hours,
                            taskId: entry.taskId
                        };
                    })
                }
            })
            .orderBy('date')
            .values()
            .value();
    }
};
