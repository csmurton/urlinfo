"use strict"
const assert = require('chai').assert;
const UrlValidator = require('../url-validator');

const validateGoodUrl = "www.fakesite.com:80/abc/1%202%203.html";
const validatePortCheck = "www.google.com";
const validateBadUrl = "www.fakesite.com:80/abc/1 2 3.html";

describe('UrlValidator', function() {
	const validator = new UrlValidator();

	it(validateGoodUrl + ' should be classed as a valid URL', function() {
		assert.isTrue(validator.validate(validateGoodUrl));
	});

	it(validateBadUrl + ' should be classed as a bad/invalid URL', function() {
		assert.isUndefined(validator.validate(validateBadUrl));
	});

	it(validatePortCheck + ' should fail validation because it doesn\'t include the port number as per spec', function() {
		assert.isUndefined(validator.validate(validatePortCheck));
	});
});
