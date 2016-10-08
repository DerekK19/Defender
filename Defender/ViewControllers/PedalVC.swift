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
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var upperKnobs: NSStackView!
    @IBOutlet weak var lowerKnobs: NSStackView!
    @IBOutlet weak var knobUpperLeft: PedalKnobControl!
    @IBOutlet weak var knobUpperMiddle: PedalKnobControl!
    @IBOutlet weak var knobUpperRight: PedalKnobControl!
    @IBOutlet weak var knobLowerLeft: PedalKnobControl!
    @IBOutlet weak var knobLowerMiddle: PedalKnobControl!
    @IBOutlet weak var knobLowerRight: PedalKnobControl!
    
    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let stompBackgroundColour = NSColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)
    let modBackgroundColour = NSColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0)
    let delayBackgroundColour = NSColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0)
    let reverbBackgroundColour = NSColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0)
    
    var fullBackgroundColour = NSColor.black
    var pedalBackgroundColour = NSColor.black
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
                self.powerLED.backgroundColour = NSColor.black
            case .off:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.pedalBackgroundColour = newBackgroundColour
            self.bodyTop.backgroundColour = newBackgroundColour
            self.bodyBottom.backgroundColour = newBackgroundColour
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
        self.state = .disabled
        self.typeLabel.stringValue = ""
        self.nameLabel.stringValue = ""
    }
    
    func configureWithPedal(_ pedal: DTOEffect?) {
        typeLabel.stringValue = pedal?.type.rawValue.uppercased() ?? ""
        nameLabel.stringValue = pedal?.name?.uppercased() ?? ""
        switch pedal?.type ?? .Unknown {
        case .Stomp:
            fullBackgroundColour = stompBackgroundColour
        case .Modulation:
            fullBackgroundColour = modBackgroundColour
        case .Delay:
            fullBackgroundColour = delayBackgroundColour
        case .Reverb:
            fullBackgroundColour = reverbBackgroundColour
        default:
            fullBackgroundColour = slotBackgroundColour
        }
        if pedal == nil {
            state = .disabled
        } else {
            state = (pedal?.enabled ?? false) ? .on : .off
        }
        if pedal?.knobCount == 1 {
            knobUpperLeft.isHidden = true
            knobUpperMiddle.isHidden = true
            knobUpperRight.isHidden = true
            knobLowerLeft.isHidden = true
            knobLowerMiddle.isHidden = false
            knobLowerRight.isHidden = true
        } else if pedal?.knobCount == 2 {
            knobUpperLeft.isHidden = true
            knobUpperMiddle.isHidden = false
            knobUpperRight.isHidden = true
            knobLowerLeft.isHidden = true
            knobLowerMiddle.isHidden = false
            knobLowerRight.isHidden = true
        } else if pedal?.knobCount == 3 {
            knobUpperLeft.isHidden = true
            knobUpperMiddle.isHidden = false
            knobUpperRight.isHidden = true
            knobLowerLeft.isHidden = false
            knobLowerMiddle.isHidden = true
            knobLowerRight.isHidden = false
        } else if pedal?.knobCount == 4 {
            knobUpperLeft.isHidden = false
            knobUpperMiddle.isHidden = true
            knobUpperRight.isHidden = false
            knobLowerLeft.isHidden = false
            knobLowerMiddle.isHidden = true
            knobLowerRight.isHidden = false
        } else if pedal?.knobCount == 5 {
            knobUpperLeft.isHidden = false
            knobUpperMiddle.isHidden = true
            knobUpperRight.isHidden = false
            knobLowerLeft.isHidden = false
            knobLowerMiddle.isHidden = false
            knobLowerRight.isHidden = false
        } else {
            knobUpperLeft.isHidden = false
            knobUpperMiddle.isHidden = false
            knobUpperRight.isHidden = false
            knobLowerLeft.isHidden = false
            knobLowerMiddle.isHidden = false
            knobLowerRight.isHidden = false
        }
    }
    
}
