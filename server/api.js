const _ = require('lodash');
const Promise = this.Promise || require('promise');
const agent = require('superagent-promise')(require('superagent'), Promise);
const holidays = require('finnish-holidays-js');
const Session = require('./schema/session')
const consts = require('./consts')

function getUser(req) {
    return req.session.passport.user;
};

function refreshAccessToken(req, res, fetchFunction) {
    findAccessToken(req, res, fetchNewAccessToken, fetchFunction)
}

function findAccessToken(req, res, callback, fetchFunction) {
    Session.findOne(
        { 'session.passport.user.harvestId': req.session.passport.user.harvestId },
        (err, result) => {
            callback(req, res, result.session.passport.user, fetchFunction)
        })
}

function fetchNewAccessToken(req, res, user, fetchFunction) {
    return agent.post(consts.harvestUrl + '/oauth2/token')
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
            updateAccessToken(user, resp.body)
            req.session.passport.user.accessToken = resp.body.access_token
            return fetchFunction(req, res)
        })
        .catch(err => {
            if (_.includes([400, 401], err.response.status)) {
                req.session.destroy(() => {
                    res.clearCookie('connect.sid', { path: '/' })
                    res.status(401).send()
                })
            }
            console.error('Error status:', err.response.status);
            console.error('Error:', err.response.body);
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
                console.log('Updated access token:', raw)
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

const yearRange = () => _.range(
    startDate.substr(0, 4),
    new Date().getFullYear() + 1)

const finnishHolidays = () =>
    _.flatMap(yearRange(), year => holidays.year(year))
        .map(h => ({
            date: `${h.year}-${padWithZero(h.month)}-${padWithZero(h.day)}`,
            name: h.description
        }))

function get(req, res, url, fetchFunction) {
    return agent.get(consts.harvestUrl + url)
        .type('json')
        .accept('json')
        .query({
            access_token: getUser(req).accessToken
        })
        .end()
        .then(resp => resp.body)
        .catch(err => {
            if (_.get(err, 'response.status') === 401) {
                refreshAccessToken(req, res, fetchFunction)
                return Promise.reject('Refreshing access token.')
            } else {
                console.error('Error:', err.response.body);
            }
        });
}

function dayEntries(entries) {
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

function fetchEntries(req, res) {
    return get(
        req, res,
        `/people/${getUser(req).harvestId}/entries?from=${startDate}&to=${formatDateForHarvest(new Date())}`,
        fetchHourEntries)
        .then(entries => {
            return _.map(entries, row => {
                return {
                    date: row.day_entry.spent_at,
                    hours: row.day_entry.hours,
                    taskId: row.day_entry.task_id
                };
            });
        })
}

function fetchHourEntries(req, res) {
    return fetchEntries(req, res)
        .then(entries => {
            res.send(dayEntries(entries))
        });
}

module.exports = {
    fetchHourEntries: fetchHourEntries,
    finnishHolidays: finnishHolidays
};
