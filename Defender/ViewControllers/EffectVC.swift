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
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var knob1: EffectKnobControl!
    @IBOutlet weak var knob2: EffectKnobControl!
    @IBOutlet weak var knob3: EffectKnobControl!
    @IBOutlet weak var knob4: EffectKnobControl!
    @IBOutlet weak var knob5: EffectKnobControl!
    @IBOutlet weak var knob6: EffectKnobControl!

    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let stompBackgroundColour = NSColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)
    let modBackgroundColour = NSColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0)
    let delayBackgroundColour = NSColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0)
    let reverbBackgroundColour = NSColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0)

    var fullBackgroundColour = NSColor.black
    var effectBackgroundColour = NSColor.black

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
            self.effectBackgroundColour = newBackgroundColour
            self.effect.backgroundColour = newBackgroundColour
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
    
    func configureWithEffect(_ effect: DTOEffect?) {
        typeLabel.stringValue = effect?.type.rawValue.uppercased() ?? ""
        nameLabel.stringValue = effect?.name?.uppercased() ?? ""
        switch effect?.type ?? .Unknown {
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
        if effect == nil {
            state = .disabled
        } else {
            state = (effect?.enabled ?? false) ? .on : .off
        }
        knob6.isHidden = effect?.knobCount ?? 0 < 6
        knob5.isHidden = effect?.knobCount ?? 0 < 5
        knob4.isHidden = effect?.knobCount ?? 0 < 4
        knob3.isHidden = effect?.knobCount ?? 0 < 4
        knob2.isHidden = effect?.knobCount ?? 0 < 2
        knob1.isHidden = effect?.knobCount ?? 0 < 1
    }
    
}