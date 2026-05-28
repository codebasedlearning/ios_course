// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

import os

struct PredefinedLogger {
    static let dataLogger = Logger(subsystem: "com.fh-aachen.ios.x04-supa-app", category: "data")
    static let databaseLogger = Logger(subsystem: "com.fh-aachen.ios.x04-supa-app", category: "database")
}
