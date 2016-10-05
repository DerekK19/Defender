//
//  EffectVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class EffectVC: NSViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var effect: EffectControl!
    @IBOutlet weak var typeLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!

    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let modBackgroundColour = NSColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0)
    let delayBackgroundColour = NSColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0)
    let reverbBackgroundColour = NSColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0)

    var fullBackgroundColour = NSColor.black
    var effectBackgroundColour = NSColor.black

    var enabledState: EnabledState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            if enabledState == .disabled {
                newBackgroundColour = slotBackgroundColour
            } else {
                newBackgroundColour = fullBackgroundColour
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.effectBackgroundColour = newBackgroundColour
            self.effect.backgroundColour = newBackgroundColour
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
                self.effectBackgroundColour = newBackgroundColour
                self.effect.backgroundColour = newBackgroundColour
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
    
    func configureWithEffect(_ effect: DTOEffect?) {
        typeLabel.stringValue = effect?.type ?? ""
        nameLabel.stringValue = effect?.name?.uppercased() ?? ""
        switch effect?.type ?? "" {
        case "STOMP BOX":
            fullBackgroundColour = slotBackgroundColour
        case "MODULATION":
            fullBackgroundColour = modBackgroundColour
        case "DELAY":
            fullBackgroundColour = delayBackgroundColour
        case "REVERB":
            fullBackgroundColour = reverbBackgroundColour
        default:
            fullBackgroundColour = slotBackgroundColour
        }
        if effect != nil {
            enabledState = .enabled
        } else {
            enabledState = .disabled
        }
    }
    
}
