const express = require('express');
const superagent = require('superagent');
const jsonParser = require('body-parser').json();

const app = express()

app.use('/', express.static(__dirname + '/dist'));

const port = 4000;
app.listen(port);
console.log('Go to http://localhost:' + port);
