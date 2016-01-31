const express = require('express');
const superagent = require('superagent');
const jsonParser = require('body-parser').json();

const app = express()

app.use('/', express.static(__dirname + '/dist'));

const port = process.env.PORT || 8080;
app.listen(port);
console.log('Server listening in port: ' + port);
