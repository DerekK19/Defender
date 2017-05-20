//
//  XMLElement+child.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension XMLElement {
    func addChild(name: String, value: Any, attributes : [String : String]) {
        let element = XMLElement(name: name, stringValue: "\(value)")
        for (key, attributeValue) in attributes {
            element.addAttribute(XMLNode.attribute(withName: key, stringValue: attributeValue) as! XMLNode)
        }
        self.addChild(element)
    }
}
