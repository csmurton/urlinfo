"use strict"
const assert = require('chai').assert;
const DummyLogger = require('./dummy-logger');
const UrlTokeniser = require('../url-tokeniser');

const tokeniseUrl = "www.fakesite.com";
const tokeniseToken = "1a1c4f91e3477ecbea27ad0ece0cc313";

const logger = new DummyLogger;

describe('UrlTokeniser', function() {
	const tokeniser = new UrlTokeniser(logger);

	it('Token ' + tokeniseToken + ' should be returned for URL ' + tokeniseUrl, function() {
		assert.equal(tokeniser.tokenise(tokeniseUrl), tokeniseToken);
	});
});
