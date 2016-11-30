//
//  PedalVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 28/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class PedalVC: UIViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var bodyTop: PedalBodyControl!
    @IBOutlet weak var bodyBottom: PedalBodyControl!
    @IBOutlet weak var pad: PedalPadControl!
    @IBOutlet weak var pedalLogo: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var textBar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var upperKnobs: UIStackView!
    @IBOutlet weak var lowerKnobs: UIStackView!
    @IBOutlet weak var knobUpperLeft: PedalKnobControl!
    @IBOutlet weak var knobUpperMiddle: PedalKnobControl!
    @IBOutlet weak var knobUpperRight: PedalKnobControl!
    @IBOutlet weak var knobLowerLeft: PedalKnobControl!
    @IBOutlet weak var knobLowerMiddle: PedalKnobControl!
    @IBOutlet weak var knobLowerRight: PedalKnobControl!
    @IBOutlet weak var shade: ShadeControl!

    var slotNumber: Int?
    var effect: DXEffect?
    
    let slotBackgroundColour = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0),
                                      2 : UIColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0),
                                      10 : UIColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0),
                                      14 : UIColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)]

    var fullBackgroundColour = UIColor.black
    var pedalBackgroundColour = UIColor.black

    var appeared = false
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = UIColor()
            self.knobUpperLeft.alpha = state == .disabled ? 0.0 : 1.0
            self.knobUpperMiddle.alpha = state == .disabled ? 0.0 : 1.0
            self.knobUpperRight.alpha = state == .disabled ? 0.0 : 1.0
            self.knobLowerLeft.alpha = state == .disabled ? 0.0 : 1.0
            self.knobLowerMiddle.alpha = state == .disabled ? 0.0 : 1.0
            self.knobLowerRight.alpha = state == .disabled ? 0.0 : 1.0
//            self.pedalLogo.alpha = state == .disabled ? 0.0 : 1.0
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
                self.powerLED.backgroundColour = UIColor.black
            case .off:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = UIColor.red
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.pedalBackgroundColour = newBackgroundColour
            self.bodyTop.backgroundColour = newBackgroundColour
            self.bodyBottom.backgroundColour = newBackgroundColour
            let currentState = self.powerState
            self.powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            self.shade.isOpen = powerState == .on || state == .disabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.powerState = .on
        self.state = .disabled
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("Appearing slot for \(self) top \(self.bodyTop) \(effect?.slot) \(fullBackgroundColour)")
//        bodyTop.backgroundColour = fullBackgroundColour
//        bodyBottom.backgroundColour = fullBackgroundColour
        appeared = true
        self.configureWith(pedal: self.effect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(pedal: DXEffect?) {
        self.effect = pedal
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? slotBackgroundColour
        NSLog("Configuring slot for \(self) top \(self.bodyTop) \(effect?.slot) \(effect?.colour) \(fullBackgroundColour)")
        if appeared {
            typeLabel.text = pedal?.type.rawValue.uppercased() ?? ""
            nameLabel.text = pedal?.name?.uppercased() ?? ""
            if pedal == nil {
                state = .disabled
            } else {
                state = (pedal?.enabled ?? false) ? .on : .off
            }
            upperKnobs.isHidden = false
            lowerKnobs.isHidden = false
            if pedal?.knobs.count == 1 {
                lowerKnobs.isHidden = true
                knobUpperLeft.isHidden = true
                knobUpperMiddle.isHidden = false
                knobUpperRight.isHidden = true
                knobLowerLeft.isHidden = true
                knobLowerMiddle.isHidden = true
                knobLowerRight.isHidden = true
                knobUpperMiddle.floatValue = pedal?.knobs[0] ?? 0
            } else if pedal?.knobs.count == 2 {
                lowerKnobs.isHidden = true
                knobUpperLeft.isHidden = false
                knobUpperMiddle.isHidden = true
                knobUpperRight.isHidden = false
                knobLowerLeft.isHidden = true
                knobLowerMiddle.isHidden = true
                knobLowerRight.isHidden = true
                knobUpperLeft.floatValue = pedal?.knobs[0] ?? 0
                knobUpperRight.floatValue = pedal?.knobs[1] ?? 0
            } else if pedal?.knobs.count == 3 {
                lowerKnobs.isHidden = true
                knobUpperLeft.isHidden = false
                knobUpperMiddle.isHidden = false
                knobUpperRight.isHidden = false
                knobLowerLeft.isHidden = true
                knobLowerMiddle.isHidden = true
                knobLowerRight.isHidden = true
                knobUpperLeft.floatValue = pedal?.knobs[0] ?? 0
                knobUpperMiddle.floatValue = pedal?.knobs[1] ?? 0
                knobUpperRight.floatValue = pedal?.knobs[2] ?? 0
            } else if pedal?.knobs.count == 4 {
                knobUpperLeft.isHidden = false
                knobUpperMiddle.isHidden = true
                knobUpperRight.isHidden = false
                knobLowerLeft.isHidden = false
                knobLowerMiddle.isHidden = true
                knobLowerRight.isHidden = false
                knobUpperLeft.floatValue = pedal?.knobs[0] ?? 0
                knobUpperRight.floatValue = pedal?.knobs[1] ?? 0
                knobLowerLeft.floatValue = pedal?.knobs[2] ?? 0
                knobLowerRight.floatValue = pedal?.knobs[3] ?? 0
            } else if pedal?.knobs.count == 5 {
                knobUpperLeft.isHidden = false
                knobUpperMiddle.isHidden = false
                knobUpperRight.isHidden = false
                knobLowerLeft.isHidden = false
                knobLowerMiddle.isHidden = true
                knobLowerRight.isHidden = false
                knobUpperLeft.floatValue = pedal?.knobs[0] ?? 0
                knobUpperMiddle.floatValue = pedal?.knobs[1] ?? 0
                knobUpperRight.floatValue = pedal?.knobs[2] ?? 0
                knobLowerLeft.floatValue = pedal?.knobs[3] ?? 0
                knobLowerRight.floatValue = pedal?.knobs[4] ?? 0
            } else if pedal?.knobs.count == 6 {
                knobUpperLeft.isHidden = false
                knobUpperMiddle.isHidden = false
                knobUpperRight.isHidden = false
                knobLowerLeft.isHidden = false
                knobLowerMiddle.isHidden = false
                knobLowerRight.isHidden = false
                knobUpperLeft.floatValue = pedal?.knobs[0] ?? 0
                knobUpperMiddle.floatValue = pedal?.knobs[1] ?? 0
                knobUpperRight.floatValue = pedal?.knobs[2] ?? 0
                knobLowerLeft.floatValue = pedal?.knobs[3] ?? 0
                knobLowerMiddle.floatValue = pedal?.knobs[4] ?? 0
                knobLowerRight.floatValue = pedal?.knobs[5] ?? 0
            }
            bodyTop.backgroundColour = fullBackgroundColour
            bodyBottom.backgroundColour = fullBackgroundColour
        }
    }
}
