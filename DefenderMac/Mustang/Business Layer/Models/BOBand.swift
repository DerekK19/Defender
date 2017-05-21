//
//  BOBand.swift
//  Mustang
//
//  Created by Derek Knight on 28/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOBand {
    
    var type: Int
    var iRepeat: Int
    var audioMix: Int
    var balance: Int
    var speed: Int
    var pitch: Int
    var songFile: BOSongFile?
    
    private var _songFile: BOSongFile?

    init(dl: DLBand) {
        self.type = dl.type
        self.iRepeat = dl.iRepeat
        self.audioMix = dl.audioMix
        self.balance = dl.balance
        self.speed = dl.speed
        self.pitch = dl.pitch
        if let dlSongFile = dl.songFile {
            self.songFile = BOSongFile(dl: dlSongFile)
            self._songFile = BOSongFile(dl: dlSongFile)
        }
    }
    
    static func convertArray(_ dls: [DLBand]) -> [BOBand] {
        return dls.map { BOBand(dl: $0) }
    }
    
    var dataObject: DLBand {
        return DLBand(withType: type,
                      iRepeat: iRepeat,
                      audioMix: audioMix,
                      balance: balance,
                      speed: speed,
                      pitch: pitch,
                      songFile: _songFile?.dataObject)
    }
}
