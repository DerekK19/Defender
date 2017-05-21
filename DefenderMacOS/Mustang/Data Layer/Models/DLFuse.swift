//
//  DLFuse.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLFuse: Mappable {
    
    var info: DLInfo?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withElement element: XMLElement) {
        if let infoElement = element.elements(forName: "Info").first {
            self.info = DLInfo(withElement: infoElement)
        }
    }
    
    init(withInfo info: DLInfo?) {
        self.info = info
    }
    
    func xml() -> XMLElement {
        let fuse = XMLElement(name: "FUSE")
        if info != nil { fuse.addChild(info!.xml()) }
        let colours = XMLElement(name: "PedalColors")
        colours.addChild(name: "Color", value: 14, attributes: ["ID" : "1"])
        colours.addChild(name: "Color", value: 1, attributes: ["ID" : "2"])
        colours.addChild(name: "Color", value: 2, attributes: ["ID" : "3"])
        colours.addChild(name: "Color", value: 10, attributes: ["ID" : "4"])
        fuse.addChild(colours)
        return fuse
    }
    
    func mapping(map: Map) {
        info             <- map["info"]
    }
}
