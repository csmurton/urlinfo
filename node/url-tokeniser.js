"use strict"
const crypto = require('crypto');

/*
   Simple Tokeniser.

   The abstraction into a class allows for the extension or replacement
   of the method in future subject to requirements.
*/

class urlTokeniser {
	constructor(logger) {
		this.logger = logger;
	}

	tokenise(url) {
		const token = crypto.createHash('md5').update(url).digest('hex');
		this.logger.log('debug', 'Generating token ' + token + ' for URL ' + url);

		return token;
	}
}

module.exports = urlTokeniser;
