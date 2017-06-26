"use strict"

/*
  URL Lookup

  This class performs the actual database query to check
  if a token exists.
*/

class urlLookup {
	constructor(config, logger, database) {
		this.logger = logger;
		this.database = database;
	}

	query(token, url) {
		var parent = this;

		return Promise.resolve().then(() => this.database.get(token).then(function(result) {
			if(result) {
				parent.logger.log('debug', 'Found token %s for %s in database', token, url);

				return result;
			} else {
				parent.logger.log('debug', 'Token %s for %s not found in database', token, url);

				return;
			}
		}));
	}
}

module.exports = urlLookup;
