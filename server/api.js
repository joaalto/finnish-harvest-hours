const _ = require('lodash');
const Promise = this.Promise || require('promise');
const agent = require('superagent-promise')(require('superagent'), Promise);

const harvestUrl = `https://${process.env.ORGANIZATION}.harvestapp.com`;

function getUser(req) {
    return req.session.passport.user;
};

function padWithZero(n) {
    return _.padStart(n, 2, '0');
};

function formatDateForHarvest(date) {
    return `${date.getFullYear()}${padWithZero(date.getMonth() + 1)}${padWithZero(date.getDate())}`;
};

const firstDayOfYear = new Date(new Date().getFullYear(), 0, 1);
const startDate = formatDateForHarvest(firstDayOfYear);
const endDate = formatDateForHarvest(new Date());

module.exports = {

    harvestUrl: harvestUrl,

    get(req, res, url) {
        return promise = agent.get(harvestUrl + url)
            .type('json')
            .accept('json')
            .query({
                access_token: getUser(req).accessToken
            })
            .end()
            .then(resp => resp.body)
            .catch(err => {
                if (err.response.status === 401) {
                    req.session.destroy();
                    res.redirect('/login');
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
                `/people/${getUser(req).id}/entries?from=${startDate}&to=${endDate}`)
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
