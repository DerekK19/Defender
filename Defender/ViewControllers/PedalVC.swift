//
//  PedalVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class PedalVC: NSViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var bodyTop: PedalBodyControl!
    @IBOutlet weak var bodyBottom: PedalBodyControl!
    @IBOutlet weak var pad: PedalPadControl!
    @IBOutlet weak var pedalLogo: NSImageView!
    @IBOutlet weak var typeLabel: NSTextField!
    @IBOutlet weak var textBar: NSBox!
    @IBOutlet weak var nameLabel: NSTextField!
    
    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let stompBackgroundColour = NSColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)
    let modBackgroundColour = NSColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0)
    let reverbBackgroundColour = NSColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0)
    
    var fullBackgroundColour = NSColor.black
    var pedalBackgroundColour = NSColor.black
    
    var enabledState: EnabledState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            if enabledState == .disabled {
                newBackgroundColour = slotBackgroundColour
                pedalLogo.isHidden = true
            } else {
                newBackgroundColour = fullBackgroundColour
                pedalLogo.isHidden = false
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.pedalBackgroundColour = newBackgroundColour
            self.pad.backgroundColour = slotBackgroundColour
            self.textBar.borderColor = NSColor.black
            self.bodyTop.backgroundColour = newBackgroundColour
            self.bodyBottom.backgroundColour = newBackgroundColour
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            if enabledState == .enabled {
                var newBackgroundColour = NSColor()
                if powerState == .off {
                    newBackgroundColour = NSColor(red: fullBackgroundColour.redComponent*0.6, green: fullBackgroundColour.greenComponent*0.6, blue: fullBackgroundColour.blueComponent*0.6, alpha: 1.0)
                } else {
                    newBackgroundColour = fullBackgroundColour
                }
                self.pedalBackgroundColour = newBackgroundColour
                self.bodyTop.backgroundColour = newBackgroundColour
                self.bodyBottom.backgroundColour = newBackgroundColour
            }
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Initialization code here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enabledState = .disabled
        self.powerState = .off
        self.typeLabel.stringValue = ""
        self.nameLabel.stringValue = ""
    }
    
    func configureWithPedal(_ pedal: DTOEffect?) {
        typeLabel.stringValue = pedal?.type ?? ""
        nameLabel.stringValue = pedal?.name?.uppercased() ?? ""
        switch pedal?.type ?? "" {
        case "STOMP BOX":
            fullBackgroundColour = stompBackgroundColour
        case "MODULATION":
            fullBackgroundColour = modBackgroundColour
        case "DELAY":
            fullBackgroundColour = stompBackgroundColour
        case "REVERB":
            fullBackgroundColour = reverbBackgroundColour
        default:
            fullBackgroundColour = slotBackgroundColour
        }
        if pedal != nil {
            enabledState = .enabled
        } else {
            enabledState = .disabled
        }
    }
    
}
