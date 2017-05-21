//
//  DLSongFile.swift
//  Mustang
//
//  Created by Derek Knight on 26/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSongFile: Mappable {
    
    var location: Int!
    var name: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withLocation location: Int, name: String?) {
        self.location = location
        self.name = name
    }
    
    init(withElement element: XMLElement) {
        self.location = element.attribute(forName: "Location")?.intValue ?? 0
        self.name = element.stringValue
    }

    func xml() -> XMLElement {
        let songFile = XMLElement(name: "SongFile")
        songFile.addAttribute(XMLNode.attribute(withName: "Location", stringValue: "\(location ?? 0)") as! XMLNode)
        songFile.stringValue = name
        return songFile
    }

    func mapping(map: Map) {
        location         <- map["Location"]
        name             <- map["Name"]
    }
}
