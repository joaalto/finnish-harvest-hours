const _ = require('lodash');
const Promise = this.Promise || require('promise');
const agent = require('superagent-promise')(require('superagent'), Promise);

function user(req) {
    return req.session.passport.user;
};

const startDate = '20160101';
const endDate = '20161231';
const baseUrl = 'https://wunderdog.harvestapp.com';

module.exports = {

    get(req, url) {
            return agent.get(baseUrl + url)
                .type('json')
                .accept('json')
                .query({
                    access_token: user(req).accessToken
                })
                .end();
        },

        projects(req) {
            const proj = this.get(req, '/projects')
                .then((resp) => {
                    return _.map(resp.body, (row) => {
                        // console.log('row:', row.project.id);
                        return row.project.id;
                    })
                });
            console.log('proj', proj);
        },

        dayEntries(req) {
            _.forEach(this.projects, (project) => {
                this.get(
                    req,
                    `/projects/${project.id}/entries?from=${startDate}&to=${endDate}&user_id=${user(req).id}`);
            });
        }
};