//
//  PedalVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 28/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol PedalVCDelegate {
    func settingsDidChangeForPedal(_ sender: PedalVC, slotNumber: Int, effect: DXEffect)
}

class PedalVC: BaseEffectVC {

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
    @IBOutlet weak var viewUpperLeft: UIView!
    @IBOutlet weak var knobUpperLeft: PedalKnobControl!
    @IBOutlet weak var labelUpperLeft: UILabel!
    @IBOutlet weak var viewUpperMiddle: UIView!
    @IBOutlet weak var knobUpperMiddle: PedalKnobControl!
    @IBOutlet weak var labelUpperMiddle: UILabel!
    @IBOutlet weak var viewUpperRight: UIView!
    @IBOutlet weak var knobUpperRight: PedalKnobControl!
    @IBOutlet weak var labelUpperRight: UILabel!
    @IBOutlet weak var viewLowerLeft: UIView!
    @IBOutlet weak var knobLowerLeft: PedalKnobControl!
    @IBOutlet weak var labelLowerLeft: UILabel!
    @IBOutlet weak var viewLowerMiddle: UIView!
    @IBOutlet weak var knobLowerMiddle: PedalKnobControl!
    @IBOutlet weak var labelLowerMiddle: UILabel!
    @IBOutlet weak var viewLowerRight: UIView!
    @IBOutlet weak var knobLowerRight: PedalKnobControl!
    @IBOutlet weak var labelLowerRight: UILabel!

    var slotNumber: Int?
    var effect: DXEffect?
    
    var delegate: PedalVCDelegate?
    
    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0),
                                      2 : UIColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0),
                                      10 : UIColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0),
                                      14 : UIColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)]

    var fullBackgroundColour = UIColor.black
    var pedalBackgroundColour = UIColor.black

    var upperLeftIndex: Int? = 0
    var upperMiddleIndex: Int? = 0
    var upperRightIndex: Int? = 0
    var lowerLeftIndex: Int? = 0
    var lowerMiddleIndex: Int? = 0
    var lowerRightIndex: Int? = 0
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = UIColor()
            knobUpperLeft.alpha = state == .disabled ? 0.0 : 1.0
            knobUpperMiddle.alpha = state == .disabled ? 0.0 : 1.0
            knobUpperRight.alpha = state == .disabled ? 0.0 : 1.0
            knobLowerLeft.alpha = state == .disabled ? 0.0 : 1.0
            knobLowerMiddle.alpha = state == .disabled ? 0.0 : 1.0
            knobLowerRight.alpha = state == .disabled ? 0.0 : 1.0
            pedalLogo.alpha = state == .disabled ? 0.6 : 1.0
            switch state {
            case .initial:
                break
            case .disabled:
                newBackgroundColour = UIColor.slotBackground
                powerLED.backgroundColour = UIColor.slotBackground
                slotLabel.isHidden = false
                pad.backgroundColour = UIColor.slotBackground
                inputLabel.textColor = UIColor.slotBackground
                outputLabel.textColor = UIColor.slotBackground
                textBar.backgroundColor = UIColor.slotBackground
            case .off:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
                pad.backgroundColour = UIColor.black
                inputLabel.textColor = UIColor.black
                outputLabel.textColor = UIColor.black
                textBar.backgroundColor = UIColor.black
            case .on:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red
                pad.backgroundColour = UIColor.black
                inputLabel.textColor = UIColor.black
                outputLabel.textColor = UIColor.black
                textBar.backgroundColor = UIColor.black
            }
            pedalBackgroundColour = newBackgroundColour
            bodyTop.backgroundColour = newBackgroundColour
            bodyBottom.backgroundColour = newBackgroundColour
            let currentState = powerState
            powerState = currentState
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .disabled
        
        knobUpperLeft.delegate = self
        knobUpperMiddle.delegate = self
        knobUpperRight.delegate = self
        knobLowerLeft.delegate = self
        knobLowerMiddle.delegate = self
        knobLowerRight.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureWith(pedal: effect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(pedal: DXEffect?) {
        self.effect = pedal
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? UIColor.slotBackground
        if appeared {
            if slotNumber != nil { slotLabel.text = "\(slotNumber! + 1)" } else { slotLabel.text = "" }
            typeLabel.text = pedal?.type.rawValue.uppercased() ?? ""
            nameLabel.text = pedal?.name?.uppercased() ?? ""
            if pedal == nil {
                state = .disabled
            } else {
                state = (pedal?.enabled ?? false) ? .on : .off
            }
            upperKnobs.isHidden = false
            lowerKnobs.isHidden = false
            upperLeftIndex = nil
            upperMiddleIndex = nil
            upperRightIndex = nil
            lowerLeftIndex = nil
            lowerMiddleIndex = nil
            lowerRightIndex = nil

            if pedal?.knobs.count == 1 {
                lowerKnobs.isHidden = true
                upperMiddleIndex = 0
            } else if pedal?.knobs.count == 2 {
                lowerKnobs.isHidden = true
                upperLeftIndex = 0
                upperRightIndex = 1
            } else if pedal?.knobs.count == 3 {
                lowerKnobs.isHidden = true
                upperLeftIndex = 0
                upperMiddleIndex = 1
                upperRightIndex = 2
            } else if pedal?.knobs.count == 4 {
                upperLeftIndex = 0
                upperRightIndex = 1
                lowerLeftIndex = 2
                lowerRightIndex = 3
            } else if pedal?.knobs.count == 5 {
                upperLeftIndex = 0
                upperMiddleIndex = 1
                upperRightIndex = 2
                lowerLeftIndex = 3
                lowerRightIndex = 4
            } else if pedal?.knobs.count == 6 {
                upperLeftIndex = 0
                upperMiddleIndex = 1
                upperRightIndex = 2
                lowerLeftIndex = 3
                lowerMiddleIndex = 4
                lowerRightIndex = 5
            }
            viewUpperLeft.isHidden = upperLeftIndex == nil
            knobUpperLeft.isHidden = upperLeftIndex == nil
            labelUpperLeft.isHidden = upperLeftIndex == nil
            viewUpperMiddle.isHidden = upperMiddleIndex == nil
            knobUpperMiddle.isHidden = upperMiddleIndex == nil
            labelUpperMiddle.isHidden = upperMiddleIndex == nil
            viewUpperRight.isHidden = upperRightIndex == nil
            knobUpperRight.isHidden = upperRightIndex == nil
            labelUpperRight.isHidden = upperRightIndex == nil
            viewLowerLeft.isHidden = lowerLeftIndex == nil
            knobLowerLeft.isHidden = lowerLeftIndex == nil
            labelLowerLeft.isHidden = lowerLeftIndex == nil
            viewLowerMiddle.isHidden = lowerMiddleIndex == nil
            knobLowerMiddle.isHidden = lowerMiddleIndex == nil
            labelLowerMiddle.isHidden = lowerMiddleIndex == nil
            viewLowerRight.isHidden = lowerRightIndex == nil
            knobLowerRight.isHidden = lowerRightIndex == nil
            labelLowerRight.isHidden = lowerRightIndex == nil

            if let index = upperLeftIndex {
                knobUpperLeft.floatValue = pedal?.knobs[index].value ?? 0
                labelUpperLeft.text = pedal?.knobs[index].name
            }
            if let index = upperMiddleIndex {
                knobUpperMiddle.floatValue = pedal?.knobs[index].value ?? 0
                labelUpperMiddle.text = pedal?.knobs[index].name
            }
            if let index = upperRightIndex {
                knobUpperRight.floatValue = pedal?.knobs[index].value ?? 0
                labelUpperRight.text = pedal?.knobs[index].name
            }
            if let index = lowerLeftIndex {
                knobLowerLeft.floatValue = pedal?.knobs[index].value ?? 0
                labelLowerLeft.text = pedal?.knobs[index].name
            }
            if let index = lowerMiddleIndex {
                knobLowerMiddle.floatValue = pedal?.knobs[index].value ?? 0
                labelLowerMiddle.text = pedal?.knobs[index].name
            }
            if let index = lowerRightIndex {
                knobLowerRight.floatValue = pedal?.knobs[index].value ?? 0
                labelLowerRight.text = pedal?.knobs[index].name
            }

            bodyTop.backgroundColour = fullBackgroundColour
            bodyBottom.backgroundColour = fullBackgroundColour
        }
    }
}

extension PedalVC: PedalKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: PedalKnobControl, value: Float) {
        if let slotNumber = slotNumber {
            if effect != nil {
                var currentValue: Float?
                switch sender {
                case knobUpperLeft:
                    currentValue = effect!.knobs[upperLeftIndex!].value
                case knobUpperMiddle:
                    currentValue = effect!.knobs[upperMiddleIndex!].value
                case knobUpperRight:
                    currentValue = effect!.knobs[upperRightIndex!].value
                case knobLowerLeft:
                    currentValue = effect!.knobs[lowerLeftIndex!].value
                case knobLowerMiddle:
                    currentValue = effect!.knobs[lowerMiddleIndex!].value
                case knobLowerRight:
                    currentValue = effect!.knobs[lowerRightIndex!].value
                default:
                    ULog.error("Don't know what knob sent this event")
                }
                
                if value != currentValue {
                    switch sender {
                    case knobUpperLeft:
                        ULog.verbose("New upper left knob is %.2f", value)
                        effect!.knobs[upperLeftIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    case knobUpperMiddle:
                        ULog.verbose("New upper middle knob is %.2f", value)
                        effect!.knobs[upperMiddleIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    case knobUpperRight:
                        ULog.verbose("New upper right knob is %.2f", value)
                        effect!.knobs[upperRightIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    case knobLowerLeft:
                        ULog.verbose("New lower left knob is %.2f", value)
                        effect!.knobs[lowerLeftIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    case knobLowerMiddle:
                        ULog.verbose("New lower middle knob is %.2f", value)
                        effect!.knobs[lowerMiddleIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    case knobLowerRight:
                        ULog.verbose("New lower right knob is %.2f", value)
                        effect!.knobs[lowerRightIndex!].value = value
                        delegate?.settingsDidChangeForPedal(self, slotNumber: slotNumber, effect: effect!)
                    default:
                        ULog.error("Don't know what knob sent this event")
                    }
                }
            } else {
                ULog.error("Can't get a knob change if there is no pedal")
            }
        }
    }
}
