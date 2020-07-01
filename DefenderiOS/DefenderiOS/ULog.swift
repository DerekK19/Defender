//
//  ULog.swift
//  noFlo
//
//  Created by Derek Knight on 20/11/19.
//  Copyright © 2019 Derek Knight. All rights reserved.
//

import Foundation
import os.log
#if os(iOS)
    #if USE_FLOGGER
        import Flogger
    #endif
#endif

private let subsystem = Bundle.main.bundleIdentifier!
private let category = "uLogger"
private let stringFormat: StaticString = "%{public}@"

class ULog {
    static func setup() {
        #if os(iOS)
            #if USE_FLOGGER
                Flogger.setup()
            #endif
        #endif
    }

    static func debug(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .default, s)
        #if os(iOS)
            #if USE_FLOGGER
                Flogger.log.debug(s)
            #endif
        #else
            NSLog(s)
        #endif
    }

    static func error(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .error, s)
        #if os(iOS)
            #if USE_FLOGGER
                Flogger.log.error(s)
            #endif
        #else
            NSLog(s)
        #endif
    }

    static func info(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        os_log(stringFormat, log: .uLogger, type: .info, s)
        #if os(iOS)
            #if USE_FLOGGER
            Flogger.log.info(s)
            #endif
        #else
            NSLog(s)
        #endif
    }

    static func verbose(_ format: StaticString, _ args: CVarArg...) {
        let f = format.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        let s = String.init(format: f, arguments: args)
        #if VERBOSE
            os_log(stringFormat, log: .uLogger, type: .debug, s)
        #endif
        #if os(iOS)
            #if USE_FLOGGER
                Flogger.log.verbose(s)
            #endif
        #else
            #if VERBOSE
                NSLog(s)
            #endif
        #endif
    }
}

extension OSLog {
    static let uLogger = OSLog(subsystem: subsystem, category: category)
}
