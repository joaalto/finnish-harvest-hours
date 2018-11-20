var _ = require('lodash');
var Promise = this.Promise || require('promise');
var agent = require('superagent-promise')(require('superagent'), Promise);
var Session = require('./schema/session')
var vars = require('./consts')

function getUser(req) {
    return req.session.passport.user;
};

function refreshAccessToken(req, res, fetchFunction) {
    findAccessToken(req, res, fetchNewAccessToken, fetchFunction)
}

function findAccessToken(req, res, callback, fetchFunction) {
    Session.findOne(
        { 'session.passport.user.harvestId': req.session.passport.user.harvestId },
        function(err, result) {
            callback(req, res, result.session.passport.user, fetchFunction)
        })
}

function fetchNewAccessToken(req, res, user, fetchFunction) {
    return agent.post(vars.harvestUrl + '/oauth2/token')
        .type('form')
        .accept('json')
        .send({
            client_id: process.env.CLIENT_ID,
            client_secret: process.env.CLIENT_SECRET,
            grant_type: 'refresh_token',
            refresh_token: user.refreshToken,
        })
        .end()
        .then(function(resp) {
            updateAccessToken(user, resp.body)
            req.session.passport.user.accessToken = resp.body.access_token
            return fetchFunction(req, res)
        })
        .catch(function(err) {
            if (_.includes([400, 401], err.response.status)) {
                req.session.destroy(function() {
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
        function(err, raw) {
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

var startDate = process.env.START_DATE;
var endDate = formatDateForHarvest(new Date());


function get(req, res, url, fetchFunction) {
    return agent.get(vars.harvestUrl + url)
        .type('json')
        .accept('json')
        .query({
            access_token: getUser(req).accessToken
        })
        .end()
        .then(function(resp){ return  resp.body})
        .catch(function(err) {
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
        .mapValues(function(dayEntries) {
            return {
                date: dayEntries[0].date,
                entries: dayEntries.map(function(entry) {
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
        .then(function(entries) {
            return _.map(entries, function(row) {
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
        .then(function(entries) {
            res.send(dayEntries(entries))
        });
}

module.exports = {
    fetchHourEntries: fetchHourEntries
};
