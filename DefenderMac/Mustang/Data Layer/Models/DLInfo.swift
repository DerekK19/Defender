//
//  DLInfo.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLInfo: Mappable {
    
    var name: String!
    var author: String!
    var rating: Int!
    var genre1: Int!
    var genre2: Int!
    var genre3: Int!
    var tags: String!
    var fenderid: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withName name: String, author: String, rating: Int, genre1: Int, genre2: Int, genre3: Int, tags: String, fenderid: Int) {
        self.name = name
        self.author = author
        self.rating = rating
        self.genre1 = genre1
        self.genre2 = genre2
        self.genre3 = genre3
        self.tags = tags
        self.fenderid = fenderid
    }
    
    init(withElement element: XMLElement) {
        self.name = element.attribute(forName: "name")?.stringValue ?? ""
        self.author = element.attribute(forName: "author")?.stringValue ?? ""
        self.rating = element.attribute(forName: "rating")?.intValue ?? 0
        self.genre1 = element.attribute(forName: "genre1")?.intValue ?? -1
        self.genre2 = element.attribute(forName: "genre2")?.intValue ?? -1
        self.genre3 = element.attribute(forName: "genre3")?.intValue ?? -1
        self.tags = element.attribute(forName: "tags")?.stringValue ?? ""
        self.fenderid = element.attribute(forName: "fenderid")?.intValue ?? 0
    }
    
    func xml() -> XMLElement {
        let info = XMLElement(name: "Info")
        info.addAttribute(XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "author", stringValue: author) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "rating", stringValue: "\(rating ?? 0)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre1", stringValue: "\(genre1 ?? -1)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre2", stringValue: "\(genre2 ?? -1)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "genre3", stringValue: "\(genre3 ?? -1)") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "tags", stringValue: tags) as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "fenderid", stringValue: "\(fenderid ?? 0)") as! XMLNode)
        return info
    }
    
    func mapping(map: Map) {
        name             <- map["name"]
        author           <- map["author"]
        rating           <- map["rating"]
        genre1           <- map["genre1"]
        genre2           <- map["genre2"]
        genre3           <- map["genre3"]
        tags             <- map["tags"]
        fenderid         <- map["fenderid"]
    }
}
