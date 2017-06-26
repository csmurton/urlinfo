"use strict"

class ConfigProvider {
	config() {
		return {
		  "Service": {
		    "ListenPort": process.env.LISTEN_PORT || 5000
		  },
		  "Database": {
		    "Provider": process.env.DATABASE_PROVIDER || 'redis',
		    "Host": process.env.DATABASE_HOST || 'localhost',
		    "Port": process.env.DATABASE_PORT || 6379,
                    "ConnectTimeout": process.env.DATABASE_CONNECT_TIMEOUT || 3000,
                    "RequestTimeout": process.env.DATABASE_REQUEST_TIMEOUT || 10000
		  },
                  "Handlers": {
                    "urlLoader": {
                      "RequestTimeout": 20000
                    }
                  },
                  "Logging": {
                    "LogLevel": process.env.LOGGING_LEVEL || 'debug'
                  }
		}
	}
}

module.exports = ConfigProvider;
