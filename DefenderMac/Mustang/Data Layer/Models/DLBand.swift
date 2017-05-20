//
//  DLBand.swift
//  Mustang
//
//  Created by Derek Knight on 26/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLBand: Mappable {
    
    var type: Int!
    var iRepeat: Int!
    var audioMix: Int!
    var balance: Int!
    var speed: Int!
    var pitch: Int!
    var songFile: DLSongFile?
    
    required init?(map: Map) {
        mapping(map: map)
    }

    init(withType type: Int, iRepeat: Int, audioMix: Int, balance: Int, speed: Int, pitch: Int, songFile: DLSongFile?) {
        self.type = type
        self.iRepeat = iRepeat
        self.audioMix = audioMix
        self.balance = balance
        self.speed = speed
        self.pitch = pitch
        self.songFile = songFile
    }
    
    init(withElement element: XMLElement) {
        self.type = element.attribute(forName: "Type")?.intValue ?? 0
        self.iRepeat = element.attribute(forName: "Repeat")?.intValue ?? 0
        self.audioMix = element.elements(forName: "AudioMix").first?.intValue ?? 0
        self.balance = element.elements(forName: "Balance").first?.intValue ?? 0
        self.speed = element.elements(forName: "Speed").first?.intValue ?? 0
        self.pitch = element.elements(forName: "Pitch").first?.intValue ?? 0
        if let songElement = element.elements(forName: "SongFile").first {
            self.songFile = DLSongFile.init(withElement: songElement)
        }
    }
    
    func xml() -> XMLElement {
        let band = XMLElement(name: "Band")
        band.addAttribute(XMLNode.attribute(withName: "Type", stringValue: "\(type ?? 0)") as! XMLNode)
        band.addAttribute(XMLNode.attribute(withName: "Repeat", stringValue: "\(iRepeat ?? 0)") as! XMLNode)
        band.addChild(songFile?.xml() ?? XMLElement(name: "SongFile"))
        band.addChild(name: "AudioMix", value: "\(audioMix ?? 0)", attributes: [:])
        band.addChild(name: "Balance", value: "\(balance ?? 0)", attributes: [:])
        band.addChild(name: "Speed", value: "\(speed ?? 0)", attributes: [:])
        band.addChild(name: "Pitch", value: "\(pitch ?? 0)", attributes: [:])
        band.addChild(XMLElement(name: "Tempo"))
        band.addChild(XMLElement(name: "Transpose"))
        band.addChild(XMLElement(name: "DrumSolo"))
        band.addChild(XMLElement(name: "CountIn"))
        return band
    }
    
    func mapping(map: Map) {
        type             <- map["Type"]
        iRepeat          <- map["Repeat"]
        audioMix         <- map["AudioMix"]
        balance          <- map["Balance"]
        speed            <- map["Speed"]
        pitch            <- map["Pitch"]
        songFile         <- map["SongFile"]
    }
}
