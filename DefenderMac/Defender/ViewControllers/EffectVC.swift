//
//  EffectVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

protocol EffectVCDelegate {
    func settingsDidChangeForEffect(_ sender: EffectVC)
}

class EffectVC: NSViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var chassis: EffectControl!
    @IBOutlet weak var typeLabel: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var knob1: EffectKnobControl!
    @IBOutlet weak var knob2: EffectKnobControl!
    @IBOutlet weak var knob3: EffectKnobControl!
    @IBOutlet weak var knob4: EffectKnobControl!
    @IBOutlet weak var knob5: EffectKnobControl!
    @IBOutlet weak var knob6: EffectKnobControl!
    @IBOutlet weak var shade: ShadeControl!

    var effect: DTOEffect?
    
    var delegate: EffectVCDelegate?

    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let bgColours: [Int : NSColor] = [1 : NSColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0),
                                      2 : NSColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0),
                                      10 : NSColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0),
                                      14 : NSColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)]
    
    var fullBackgroundColour = NSColor.black
    var effectBackgroundColour = NSColor.black

    let verbose = true
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
                self.powerLED.backgroundColour = NSColor.black
                self.knob1.isHidden = true
                self.knob2.isHidden = true
                self.knob3.isHidden = true
                self.knob4.isHidden = true
                self.knob5.isHidden = true
                self.knob6.isHidden = true
            case .off:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.effectBackgroundColour = newBackgroundColour
            self.chassis.backgroundColour = newBackgroundColour
            let currentState = self.powerState
            self.powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            self.shade.isOpen = powerState == .on || state == .disabled
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
        
        knob1.delegate = self
        knob2.delegate = self
        knob3.delegate = self
        knob4.delegate = self
        knob5.delegate = self
        knob6.delegate = self
    }
    
    func configureWithEffect(_ effect: DTOEffect?) {
        self.effect = effect
        delegate = nil
        typeLabel.stringValue = effect?.type.rawValue.uppercased() ?? ""
        nameLabel.stringValue = effect?.name?.uppercased() ?? ""
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? slotBackgroundColour
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
        
        if effect?.knobCount ?? 0 > 0 {
            knob1.floatValue = effect?.knobs[0].value ?? 0
        }
        if effect?.knobCount ?? 0 > 1 {
            knob2.floatValue = effect?.knobs[1].value ?? 0
        }
        if effect?.knobCount ?? 0 > 2 {
            knob3.floatValue = effect?.knobs[2].value ?? 0
        }
        if effect?.knobCount ?? 0 > 3 {
            knob4.floatValue = effect?.knobs[3].value ?? 0
        }
        if effect?.knobCount ?? 0 > 4 {
            knob5.floatValue = effect?.knobs[4].value ?? 0
        }
        if effect?.knobCount ?? 0 > 5 {
            knob6.floatValue = effect?.knobs[5].value ?? 0
        }
    }
    
    // MARK: Debug logging
    internal func DebugPrint(_ text: String) {
        if (verbose) {
            print(text)
        }
    }

}

extension EffectVC: EffectKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: EffectKnobControl, value: Float) {
        switch sender {
        case knob1:
            DebugPrint("New knob 1 is \(value)")
            effect!.knobs[0].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob2:
            DebugPrint("New knob 2 is \(value)")
            effect!.knobs[1].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob3:
            DebugPrint("New knob 3 is \(value)")
            effect!.knobs[2].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob4:
            DebugPrint("New knob 4 is \(value)")
            effect!.knobs[3].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob5:
            DebugPrint("New knob 5 is \(value)")
            effect!.knobs[4].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob6:
            DebugPrint("New knob 5 is \(value)")
            effect!.knobs[5].value = value
            delegate?.settingsDidChangeForEffect(self)
        default:
            NSLog("Don't know what knob sent this event")
        }
    }
}

