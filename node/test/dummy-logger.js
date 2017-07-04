"use strict"

class DummyLogger {
        log(level, message) {
                return true;
        }
}

module.exports = DummyLogger;
