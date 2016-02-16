const _ = require('lodash');
const request = require('superagent');

module.exports = {
    transformDayEntries: function() {
        console.log('...');
    },

    get: function(req, url) {
        request.get('https://wunderdog.harvestapp.com' + url)
            .type('json')
            .accept('json')
            .query({
                access_token: req.session.passport.user.accessToken
            })
            .end((err, result) => {
                if (err) {
                    console.log('error:', err);
                } else {
                    // console.log('result:', result);
                    return result;
                }
            });
    }

};