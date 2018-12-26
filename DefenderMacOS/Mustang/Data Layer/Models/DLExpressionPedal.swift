//
//  DLExpressionPedal.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLExpressionPedal: Mappable {
    
    var volumeModeBehavior: Int!
    var expressionModeBehavior: Int!
    var heelSetting: Int!
    var toeSetting: Int!
    var pedalMode: Int!
    var bypassEffectWhenVolumeMode: Int!
    var volumeSwitchRevert: Int!
    var defaultPedalState: Int!
    var pedalOverrideState: Int!
    var parameterIndex: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withElement element: XMLElement) {
        self.volumeModeBehavior = element.attribute(forName: "VolumeModeBehavior")?.intValue ?? 0
        self.expressionModeBehavior = element.attribute(forName: "ExpressionModeBehavior")?.intValue ?? 0
        self.heelSetting = element.attribute(forName: "HeelSetting")?.intValue ?? 0
        self.toeSetting = element.attribute(forName: "ToeSetting")?.intValue ?? 0
        self.pedalMode = element.attribute(forName: "PedalMode")?.intValue ?? 0
        self.bypassEffectWhenVolumeMode = element.attribute(forName: "BypassEffectWhenVolumeMode")?.intValue ?? 0
        self.volumeSwitchRevert = element.attribute(forName: "VolumeSwitchRevert")?.intValue ?? 0
        self.defaultPedalState = element.attribute(forName: "DefaultPedalState")?.intValue ?? 0
        self.pedalOverrideState = element.attribute(forName: "PedalOverrideState")?.intValue ?? 0
        self.parameterIndex = element.attribute(forName: "ParameterIndex")?.intValue ?? 0
    }
    
    func xml() -> XMLElement {
        let info = XMLElement(name: "FirstExpressionPedal")
        info.addAttribute(XMLNode.attribute(withName: "VolumeModeBehavior", stringValue: "\(String(describing: volumeModeBehavior))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ExpressionModeBehavior", stringValue: "\(String(describing: expressionModeBehavior))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "HeelSetting", stringValue: "\(String(describing: heelSetting))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ToeSetting", stringValue: "\(String(describing: toeSetting))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "PedalMode", stringValue: "\(String(describing: pedalMode))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "BypassEffectWhenVolumeMode", stringValue: "\(String(describing: bypassEffectWhenVolumeMode))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "VolumeSwitchRevert", stringValue: "\(String(describing: volumeSwitchRevert))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "DefaultPedalState", stringValue: "\(String(describing: defaultPedalState))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "PedalOverrideState", stringValue: "\(String(describing: pedalOverrideState))") as! XMLNode)
        info.addAttribute(XMLNode.attribute(withName: "ParameterIndex", stringValue: "\(String(describing: parameterIndex))") as! XMLNode)
        return info
    }
    
    func mapping(map: Map) {
        volumeModeBehavior         <- map["volumeModeBehavior"]
        expressionModeBehavior     <- map["expressionModeBehavior"]
        heelSetting                <- map["heelSetting"]
        toeSetting                 <- map["toeSetting"]
        pedalMode                  <- map["pedalMode"]
        bypassEffectWhenVolumeMode <- map["bypassEffectWhenVolumeMode"]
        volumeSwitchRevert         <- map["volumeSwitchRevert"]
        defaultPedalState          <- map["defaultPedalState"]
        pedalOverrideState         <- map["pedalOverrideState"]
        parameterIndex             <- map["parameterIndex"]
    }
}
