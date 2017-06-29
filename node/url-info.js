"use strict"
const winston = require('winston');
const Promise = require('bluebird');
const awsServerlessExpress = require('aws-serverless-express');
const isLambda = require('is-lambda');
const express = require('express');
const url = require('url');

const ConfigProvider = require('./config')
const UrlTokeniser = require('./url-tokeniser')
const UrlDatabase = require('./url-database')
const UrlLookup = require('./url-lookup')
const UrlLoader = require('./url-loader')
const UrlValidator = require('./url-validator')

const app = express();
const server = awsServerlessExpress.createServer(app);
const logger = new winston.Logger();

const config = new ConfigProvider().config();

logger.configure({
  level: config.Logging.LogLevel,
  transports: [
    new (winston.transports.Console)()
  ]
});

const tokeniser = new UrlTokeniser(logger);
const validator = new UrlValidator(logger);
const database = new UrlDatabase(config, logger, Promise);
const lookup = new UrlLookup(config, logger, database);
const loader = new UrlLoader(config, logger, database, validator, tokeniser);

function errorHandler(err, req, res, next) {
	res.status(500).json({'error': err });
}

function urlLoaderHandler(request, response, next) {
	logger.log('debug', 'Received urlLoader request');

	return new Promise(function (resolve, reject) {
		// Load sample/demo 3rd party blacklist into database backend.

		loader.load().then(function(result) {
			response.statusCode = 200;
			resolve(response.json({ 'message': 'URLs imported to database successfully.' }));
		});
	})
	.timeout(config.Handlers.urlLoader.RequestTimeout)
	.catch(Promise.TimeoutError, function(err) {
		// Timeout waiting for import.

		response.statusCode = 503;
		response.json({ 'error': 'URLs could not be imported within ' + config.Handlers.urlLoader.RequestTimeout + 'ms. Please try again later.' });
	});
}

function urlInfoHandler(request, response, next) {
	const reqHost = request.params.host;
	const reqPath = request.params.path;

	logger.log('debug', 'Received urlInfo request for host %s and path %s', reqHost, (reqPath ? reqPath: 'none'));

	/* We want to compare the fully assembled URL and also any
	block which applies to the whole host. */

	const formattedUrl = url.format(reqHost + (reqPath ? '/' + reqPath: '/'));
	const tokenUrl = tokeniser.tokenise(formattedUrl);

	const formattedHost = url.format(reqHost + '/');
	const tokenHost = tokeniser.tokenise(formattedHost);

	return new Promise(function (resolve, reject) {
		if(!validator.validate(formattedUrl)) {
			response.statusCode = 400;
			resolve(response.json({'error': 'The URL provided is not syntactically valid. Expected format is "host:port/path"'}));
		} else {
			/* Attempt a database lookup for the token for host only */

			lookup.query(tokenHost, formattedHost).then(function(result) {
				if(result) {
					// Found our host token. Request is malicious.
					response.statusCode = 200;
					var malicious = true;

					resolve(response.json({ 'malicious': malicious, 'metadata': (result ? JSON.parse(result): result) }));
				} else if(tokenHost == tokenUrl) {
					// Did not find our host token and the URL token is identical

					response.statusCode = 404;
					var malicious = false;

					resolve(response.json({ 'malicious': malicious, 'metadata': (result ? JSON.parse(result): result) }));
				} else {
					// Did not find our host token and the URL token is different; look up URL token

					lookup.query(tokenUrl, formattedUrl).then(function(result) {
						var malicious;

						if(result) {
							// Found our full URL's token. Request is malicious.

							response.statusCode = 200;
							malicious = true;
						} else {
							// Did not find our full URL's token. Request is not malicious.

							response.statusCode = 404;
							malicious = false;
						}

						resolve(response.json({ 'malicious': malicious, 'metadata': (result ? JSON.parse(result): result) }));
					});
				}
			});
		}
	})
	.timeout(config.Database.RequestTimeout)
	.catch(Promise.TimeoutError, function(err) {
		// Timeout waiting for a response from the database backend.
		logger.log('error', 'Database backend did not respond within %s milliseconds, sending error response', config.Database.RequestTimeout);

		response.statusCode = 503;
		response.json({ 'error': 'A response was not received within the timeframe. Please try again later.' });
	});
}

// Define routes
app.get('/urlinfo/1/:host/:path(*)?', urlInfoHandler);
app.get('/urlloader', urlLoaderHandler);
app.use(errorHandler);

// Provider a 'handler' export to be used by AWS Lambda if invoked in this way.
exports.handler = (event, context) => awsServerlessExpress.proxy(server, event, context);

// If not invoked by Lambda, assume we're running standalone and bind to a port.
if(!isLambda) {
  return Promise.promisify(app.listen, {context: app})(config.Service.ListenPort)
	.then(logger.log('info', 'Listening on port ' + config.Service.ListenPort));
}
