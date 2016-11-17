//
//  DXRequest.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

internal enum RequestType : String {
    case amplifier = "AMPLIFIER"
}

internal struct DXRequest: Transferable {
    
    var command: RequestType
    
    init(command: RequestType) {
        self.command = command
    }
    
    init(data: Data) throws {
        if let string = String(data: data, encoding: .utf8),
           let command = RequestType(rawValue: string) {
            self.command = command
            return
        }
        throw TransferError.serialising
    }
    
    var data: Data? {
        let string = command.rawValue
        return string.data(using: .utf8)
    }
}
