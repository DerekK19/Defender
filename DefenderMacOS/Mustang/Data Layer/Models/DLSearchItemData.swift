//
//  DLSearchItemData.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchItemData: Mappable {
    
    var filename: String!
    var size: Int!
    var content: String?
    var preset: DLPreset? {
        get {
            var rValue: DLPreset? = nil
            if let content = content {
                let document: XMLDocument?
                do {
                    document = try XMLDocument(xmlString: content, options: XMLNode.Options(rawValue: 0))
                    if let document = document {
                        rValue = try DLPreset(xml: document)
                    }
                }
                catch { }
            }
            return rValue
        }
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withFilename filename: String, preset: DLPreset) {
        let doc = preset.xml()
        self.filename = filename
        self.content = doc.xmlString
        self.size = self.content?.count ?? 0
    }
    
    func mapping(map: Map) {
        filename       <- map["filename"]
        size           <- map["size"]
        content        <- map["content"]
    }
    
}
