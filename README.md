### Requirements

- Heroku toolbelt: https://toolbelt.heroku.com/
- Node JS with ES6 support
- MongoDB (for storing user sessions)
- local-ssl-proxy: `npm install -g local-ssl-proxy`  
- nodemon: `npm install -g nodemon`
- `.env` file in project root with the required environment variables

### Running locally

`./run-local`

Go to https://localhost:5001/

### TODO  

- proper error messages
- UX
- handle refresh tokens, currently need to re-login when the access token expires after 17 h
- tests
- maybe replace the server with SUPERIOR HASKELL TECHNOLOGY
