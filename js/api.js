const _ = require('lodash');
const Promise = this.Promise || require('promise');
const agent = require('superagent-promise')(require('superagent'), Promise);

function getUser(req) {
    return req.session.passport.user;
};

const startDate = '20160101';
const endDate = '20161231';
const baseUrl = 'https://wunderdog.harvestapp.com';

module.exports = {

    get(req, url) {
        return promise = agent.get(baseUrl + url)
            .type('json')
            .accept('json')
            .query({
                access_token: getUser(req).accessToken
            })
            .end()
            .then(resp => resp.body)
            .catch(err => {
                if (err.response.status === 401) {
                    // TODO: login again, add ttl to session
                    req.session.destroy();
                }
                console.error('error:', err.response);
            });
    },

    fetchHourEntries(req) {
        return this.get(req, '/projects')
            .then(projects => _.map(projects, row => row.project.id))
            .then(projectIds => this.dayEntries(req, projectIds));
    },

    fetchProjectsAndEntries(req, projectIds) {
        return _.map(projectIds, projectId => {
            return this.get(
                    req,
                    `/projects/${projectId}/entries?from=${startDate}&to=${endDate}&user_id=${getUser(req).id}`)
                .then(projectEntries => {
                    return _.map(projectEntries, row => {
                        return {
                            date: row.day_entry.spent_at,
                            hours: row.day_entry.hours
                        };
                    });
                })
                .catch(err => console.error('>>> error:', err));
        });
    },

    dayEntries(req, projectIds) {
        return Promise.all(this.fetchProjectsAndEntries(req, projectIds))
            .then(results => _(results)
                .flatten()
                .groupBy('date')
                .mapValues(dayEntries => {
                    return dayEntries.reduce((a, b) => {
                        return {
                            date: a.date,
                            hours: a.hours + b.hours
                        };
                    })
                })
                .values()
                .value())
            .catch(err => console.error('ERR:', err));
    }
};