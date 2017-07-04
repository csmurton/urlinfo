"use strict"
const assert = require('chai').assert;
const ConfigProvider = require('../config');

describe('Config', function() {
	const config = new ConfigProvider().config();

	it('Check Config provider is providing an Object', function() {
		assert.isObject(config);
	});

	it('Check that Config has a Database Host property', function() {
		assert.nestedProperty(config, 'Database.Host');
	});
});
