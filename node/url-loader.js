"use strict"
const fs = require('fs');
const download = require('download');
const path = require('path');
const url = require('url');

/*
  URL Loader

  This class is used to prime the database with a 3rd party
  blacklist for demonstration purposes.

  node_redis doesn't natively support streams, so we won't use
  them for this one off.
*/

class urlLoader {
	constructor(config, logger, database, validator, tokeniser) {
		this.logger = logger;
		this.database = database;
		this.validator = validator;
		this.tokeniser = tokeniser;
	}

	_walk_directory(root, callback, subdirectory) {
		var parent = this;
		var abspath = subdirectory ? path.join(root, subdirectory) : root;

		fs.readdirSync(abspath).forEach(function(filename) {
			var filepath = path.join(abspath, filename);

			if (fs.statSync(filepath).isDirectory()) {
				parent._walk_directory(root, callback, path.join(subdirectory || '', filename || ''));
			} else {
				callback(filepath, root, subdirectory, filename);
			}
		});
	}

        load() {
		var parent = this;
		var blacklistUrl = 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=smalltestlist';
		var blacklistTargetPath = '/tmp/blacklist';
		var fakeUrl = 'url-info-test.fake:80/test.html';

		return Promise.resolve().then(() => download(blacklistUrl, blacklistTargetPath, { 'extract': true }).then(() => {
			parent.logger.log("Downloaded blacklist from %s", blacklistUrl);

			// Add a fake URL token to the database for unit testing
			parent.database.set(this.tokeniser.tokenise(fakeUrl), '{ "category": "dummy" }').then(function(result) {
				parent.logger.log("debug", "Adding test token to the database");
			});

			this._walk_directory(blacklistTargetPath, function(filepath, root, subdirectory, filename) {
				var category = filepath.match(/.*\/([^\/]+)\/.*$/)[1];

				var readStream = fs.createReadStream(filepath, 'utf8');
				var data = '';

				readStream.on('data', function(chunk) {
					data += chunk;
				}).on('end', function() {
					// We now need to split the file line by line to parse,
					// tokenise and store in the database.

					data.toString().split("\n").forEach(function(line, index, arr) {
						// If last line or line is empty, return.
						if(line === "") { return; };
						if(index === arr.length - 1) { return; };

						// Split blacklist entry into component parts.
						var urlParts = line.match(/([^\/]+)\/?(.*)$/);

						if(urlParts) {
							// Add :80 here because source blacklist doesn't contain
							// port numbers but our API expects it to be provided.

							const formattedUrl = url.format(urlParts[1].toLowerCase() + ':80' + (urlParts[2] ? '/' + urlParts[2]: '/'));

							if(!parent.validator.validate(formattedUrl)) {
								parent.logger.log("debug", "Not adding token for URL %s as it did not pass validation", formattedUrl);
							} else {
								const urlToken = parent.tokeniser.tokenise(formattedUrl);

								parent.database.set(urlToken, '{ "category": "' + category + '" }').then(function(result) {
									parent.logger.log("debug", "Adding token %s for %s to database", urlToken, formattedUrl);
								});
							}
						}
					});
				});
			});
		}));
	}
}

module.exports = urlLoader;
