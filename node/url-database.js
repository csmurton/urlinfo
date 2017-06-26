"use strict"

/*
  URL Database

  This class provides the various methods for interacting with
  the database.
*/

class UrlDatabase {
	constructor(config, logger, Promise) {
		this.logger = logger;
		var parent = this;

		switch(config.Database.Provider) {
			case "redis":
				const redis = Promise.promisifyAll(require('redis'));

				this.logger.log("debug", "Creating database connection with provider '" + config.Database.Provider + "', host = " + config.Database.Host + ":" + config.Database.Port);

				this.database = redis.createClient({
					host: config.Database.Host,
					port: config.Database.Port,
					connect_timeout: config.Database.ConnectTimeout
				});

				this.database.on("connect", function () {
					parent.logger.log("debug", "Successfully connected to database");
				});

				this.database.on("error", function (err) {
					parent.logger.log("error", "Redis database provider error: " + err);
				});
				break;
			default:
				throw new Error('Database provider not implemented');
				break;
		}
	}

	get(token) {
		this.logger.log("debug", "Querying database for token " + token);

		return Promise.resolve(this.database.getAsync(token));
	}

	set(token, value) {
		this.logger.log("debug", "Updating database with token " + token + ", value = " + value);
		return Promise.resolve(this.database.setAsync(token, value));
	}

	delete(token) {
		this.logger.log("debug", "Deleting token " + token + " from database");
		return Promise.resolve(this.database.deleteAsync(token));
	}

	empty() {
		this.logger.log("debug", "Emptying all tokens from database");
		return Promise.resolve(this.database.flushdbAsync());
	}
}

module.exports = UrlDatabase;
