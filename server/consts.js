module.exports = {

    mongoUrl: process.env.MONGOLAB_URI || 'mongodb://localhost/saldot',
    harvestUrl: `https://${process.env.ORGANIZATION}.harvestapp.com`
}
