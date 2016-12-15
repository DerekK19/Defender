//
//  CabinetVC.swift
//  Defender
//
//  Created by Derek Knight on 14/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang
import Flogger

protocol CabinetVCDelegate {
    func settingsDidChangeForCabinet(_ sender: CabinetVC)
}

class CabinetVC: NSViewController {
    
    @IBOutlet weak var slot: CabinetSlotControl!
    @IBOutlet weak var effectLead: NSBox!
    @IBOutlet weak var pedalLead: NSBox!
    @IBOutlet weak var cabinet: CabinetControl!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var shade: ShadeControl!
    
    var delegate: CabinetVCDelegate?
    
    let slotBackgroundColour = NSColor.slotBackground
    let bgColours: [Int : NSColor] = [1 : NSColor.purpleEffect,
                                      2 : NSColor.greyEffect,
                                      10 : NSColor.blueEffect,
                                      14 : NSColor.greenEffect]
    
    var fullBackgroundColour = NSColor.black
    var cabinetBackgroundColour = NSColor.black
    
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
            self.cabinetBackgroundColour = newBackgroundColour
            self.effectLead.borderColor = NSColor.lead
            self.pedalLead.borderColor = NSColor.lead
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
    }
    
    func configureWithEffect(_ effect: DTOEffect?) {
//        self.effect = effect
        delegate = nil
        fullBackgroundColour = slotBackgroundColour
        if effect == nil {
            state = .disabled
        } else {
            state = (effect?.enabled ?? false) ? .on : .off
        }
    }
}
