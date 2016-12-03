//
//  PedalVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 28/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger

protocol PedalVCDelegate {
    func settingsDidChangeForPedal(_ sender: PedalVC)
}

class PedalVC: UIViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var shade: ShadeControl!
    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var bodyTop: PedalBodyControl!
    @IBOutlet weak var bodyBottom: PedalBodyControl!
    @IBOutlet weak var pad: PedalPadControl!
    @IBOutlet weak var pedalLogo: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
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

    var slotNumber: Int?
    var effect: DXEffect?
    
    var delegate: PedalVCDelegate?
    
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
            self.pedalLogo.alpha = state == .disabled ? 0.6 : 1.0
            switch state {
            case .disabled:
                newBackgroundColour = UIColor.slotBackground
                self.powerLED.backgroundColour = UIColor.slotBackground
                slotLabel.isHidden = false
                self.pad.backgroundColour = UIColor.slotBackground
                self.inputLabel.textColor = UIColor.slotBackground
                self.outputLabel.textColor = UIColor.slotBackground
                self.textBar.backgroundColor = UIColor.slotBackground
            case .off:
                newBackgroundColour = fullBackgroundColour
                self.slotLabel.isHidden = true
                self.powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
                self.pad.backgroundColour = UIColor.black
                self.inputLabel.textColor = UIColor.black
                self.outputLabel.textColor = UIColor.black
                self.textBar.backgroundColor = UIColor.black
            case .on:
                newBackgroundColour = fullBackgroundColour
                self.slotLabel.isHidden = true
                self.powerLED.backgroundColour = UIColor.red
                self.pad.backgroundColour = UIColor.black
                self.inputLabel.textColor = UIColor.black
                self.outputLabel.textColor = UIColor.black
                self.textBar.backgroundColor = UIColor.black
            }
            self.pedalBackgroundColour = newBackgroundColour
            self.bodyTop.backgroundColour = newBackgroundColour
            self.bodyBottom.backgroundColour = newBackgroundColour
            let currentState = self.powerState
            self.powerState = currentState
        }
    }
    
    internal var powerState: PowerState = .off {
        didSet {
            if appeared {
                self.shade.state = state == .disabled ? .closed : powerState == .on ? .open : .ajar
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.powerState = .off
        self.state = .disabled
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appeared = true
        self.configureWith(pedal: self.effect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(pedal: DXEffect?) {
        self.effect = pedal
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? UIColor.slotBackground
        if appeared {
            if slotNumber != nil { slotLabel.text = "\(self.slotNumber! + 1)" } else { slotLabel.text = "" }
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

extension PedalVC: PedalKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: PedalKnobControl, value: Float) {
        if effect != nil {
            var currentValue: Float?
            switch sender {
            case knobUpperLeft:
                currentValue = effect!.knobs[0]
            case knobUpperMiddle:
                currentValue = effect!.knobs[1]
            case knobUpperRight:
                currentValue = effect!.knobs[2]
            case knobLowerLeft:
                currentValue = effect!.knobs[3]
            case knobLowerMiddle:
                currentValue = effect!.knobs[4]
            case knobLowerRight:
                currentValue = effect!.knobs[5]
            default:
                Flogger.log.error("Don't know what knob sent this event")
            }
            
            if value != currentValue {
                switch sender {
                case knobUpperLeft:
                    Flogger.log.debug("New upper left knob is \(value)")
                    effect!.knobs[0] = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobUpperMiddle:
                    Flogger.log.debug("New upper middle knob is \(value)")
                    effect!.knobs[1] = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobUpperRight:
                    Flogger.log.debug("New upper right knob is \(value)")
                    effect!.knobs[2] = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerLeft:
                    Flogger.log.debug("New lower left knob is \(value)")
                    effect!.knobs[3] = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerMiddle:
                    Flogger.log.debug("New lower middle knob is \(value)")
                    effect!.knobs[4] = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerRight:
                    Flogger.log.debug("New lower right knob is \(value)")
                    effect!.knobs[5] = value
                    delegate?.settingsDidChangeForPedal(self)
                default:
                    Flogger.log.error("Don't know what knob sent this event")
                }
            }
        } else {
            Flogger.log.error("Can't get a knob change if there is no pedal")
        }
    }
}
