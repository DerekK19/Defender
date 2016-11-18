//
//  DXRequest.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal enum RequestType : String {
    case amplifier = "AMPLIFIER"
}

internal class DXMessage: Mappable, Transferable {
    
    var command: RequestType!
    var content: Transferable?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(command: RequestType, data: Transferable?) {
        self.command = command
        self.content = data
    }
    
    required init(data: Data) throws {
        if let string = String(data: data, encoding: .utf8),
            let temp = Mapper<DXMessage>().map(JSONString: string) {
            self.command = temp.command
            self.content = temp.content
            return
        }
        throw TransferError.serialising
    }
    
    var data: Data? {
        get {
            if let string = self.toJSONString() {
                return string.data(using: .utf8)
            }
            return nil
        }
    }
    
    func mapping(map: Map) {
        command         <- map["command"]
        content         <- map["content"]
    }
}
