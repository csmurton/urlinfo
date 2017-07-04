"use strict"
const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;

process.env['LISTEN_PORT'] = 29950;
process.env['LOGGING_LEVEL'] = "none";

const UrlInfo = require('../url-info');

const urlInfoTestUrl = "url-info-test.fake:80/test.html";

chai.use(chaiHttp);

describe('UrlInfo', function() {
	it('Expect a non-HTTP 500 response code when performing a GET request for URL info on ' + urlInfoTestUrl, function(done) {
		// Set timeout over 10000ms as this is the default timeout if the database backend isn't available.

		this.timeout(15000);

		chai.request(UrlInfo.app).get('/urlinfo/1/' + urlInfoTestUrl)
			.end(function(err, res) {
				expect(res).to.not.have.status(500);
				done();
		});
	});

	it('Look for a 404 HTTP response for a known unmapped route', function(done) {
		chai.request(UrlInfo.app).get('/fakepath')
			.end(function(err, res) {
				expect(res).to.have.status(404);
				done();
		});
	});
});
