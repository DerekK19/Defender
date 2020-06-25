//
//  EffectVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol EffectVCDelegate {
    func settingsDidChangeForEffect(_ sender: EffectVC)
}

class EffectVC: NSViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var effectLead: NSBox!
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

    var effect: BOEffect?
    
    var delegate: EffectVCDelegate?

    let slotBackgroundColour = NSColor.slotBackground
    let bgColours: [Int : NSColor] = [1 : NSColor.purpleEffect,
                                      2 : NSColor.greyEffect,
                                      10 : NSColor.blueEffect,
                                      14 : NSColor.greenEffect]
    
    var fullBackgroundColour = NSColor.black
    var effectBackgroundColour = NSColor.black

    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            switch state {
            case .disabled:
                newBackgroundColour = NSColor.clear
                powerLED.backgroundColour = NSColor.black
                knob1.isHidden = true
                knob2.isHidden = true
                knob3.isHidden = true
                knob4.isHidden = true
                knob5.isHidden = true
                knob6.isHidden = true
            case .off:
                newBackgroundColour = fullBackgroundColour
                powerLED.backgroundColour = NSColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                powerLED.backgroundColour = NSColor.red
            }
            slot.backgroundColour = slotBackgroundColour
            effectBackgroundColour = newBackgroundColour
            effectLead.borderColor = NSColor.lead
            chassis.backgroundColour = newBackgroundColour
            let currentState = powerState
            powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            shade.isOpen = powerState == .on || state == .disabled
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Initialization code here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = .disabled
        typeLabel.stringValue = ""
        nameLabel.stringValue = ""
        
        knob1.delegate = self
        knob2.delegate = self
        knob3.delegate = self
        knob4.delegate = self
        knob5.delegate = self
        knob6.delegate = self
    }
    
    func configureWithEffect(_ effect: BOEffect?) {
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
        knob3.isHidden = effect?.knobCount ?? 0 < 3
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
    
}

extension EffectVC: EffectKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: EffectKnobControl, value: Float) {
        switch sender {
        case knob1:
            ULog.debug("New knob 1 is %.2f", value)
            effect!.knobs[0].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob2:
            ULog.debug("New knob 2 is %.2f", value)
            effect!.knobs[1].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob3:
            ULog.debug("New knob 3 is %.2f", value)
            effect!.knobs[2].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob4:
            ULog.debug("New knob 4 is %.2f", value)
            effect!.knobs[3].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob5:
            ULog.debug("New knob 5 is %.2f", value)
            effect!.knobs[4].value = value
            delegate?.settingsDidChangeForEffect(self)
        case knob6:
            ULog.debug("New knob 6 is %.2f", value)
            effect!.knobs[5].value = value
            delegate?.settingsDidChangeForEffect(self)
        default:
            ULog.error("Don't know what knob sent this event")
        }
    }
}


