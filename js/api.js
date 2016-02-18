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

    projects(req) {
        const proj = this.get(req, '/projects')
            .then(projects => _.map(projects, row => row.project.id))
            .then(projectIds => this.dayEntries(req, projectIds));

        console.log('proj:', proj);
    },

    dayEntries(req, projectIds) {
        return Promise.all(_.forEach(projectIds, projectId => {
                return this.get(
                        req,
                        `/projects/${projectId}/entries?from=${startDate}&to=${endDate}&user_id=${getUser(req).id}`)
                    .then(entries => {
                        return _.map(entries, entry => {
                            return {
                                date: entry.spent_at,
                                hours: entry.hours
                            };
                        });
                    })
                    .catch(err => console.error('>>> error:', err));
            })).then(res => {
                console.log('>>> res', res);
                return res;
            })
            .catch(err => console.error('ERR:', err));
    }
};