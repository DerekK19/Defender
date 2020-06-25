//
//  EffectVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol EffectVCDelegate {
    func settingsDidChangeForEffect(_ sender: EffectVC, slotNumber: Int, effect: DXEffect)
}

class EffectVC: BaseEffectVC {

    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var chassis: EffectControl!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var knob1: EffectKnobControl!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var knob2: EffectKnobControl!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var knob3: EffectKnobControl!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var knob4: EffectKnobControl!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var knob5: EffectKnobControl!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var knob6: EffectKnobControl!
    @IBOutlet weak var label6: UILabel!

    var delegate: EffectVCDelegate?
    
    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0),
                                      2 : UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0),
                                      10 : UIColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0),
                                      14 : UIColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)]
    
    var fullBackgroundColour = UIColor.black
    var effectBackgroundColour = UIColor.black
    
    var slotNumber: Int?
    var effect: DXEffect?
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = UIColor()
            switch state {
            case .initial:
                break
            case .disabled:
                newBackgroundColour = UIColor.slotBackground
                slotLabel.isHidden = false
                powerLED.backgroundColour = UIColor.slotBackground
                knob1.isHidden = true
                label1.isHidden = true
                knob2.isHidden = true
                label2.isHidden = true
                knob3.isHidden = true
                label3.isHidden = true
                knob4.isHidden = true
                label4.isHidden = true
                knob5.isHidden = true
                label5.isHidden = true
                knob6.isHidden = true
                label6.isHidden = true
            case .off:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red
            }
            effectBackgroundColour = newBackgroundColour
            chassis.backgroundColour = newBackgroundColour
            let currentState = powerState
            powerState = currentState
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .disabled
        
        knob1.delegate = self
        knob2.delegate = self
        knob3.delegate = self
        knob4.delegate = self
        knob5.delegate = self
        knob6.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureWith(effect: effect)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(effect: DXEffect?) {
        self.effect = effect
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? UIColor.slotBackground
        if appeared {
            if slotNumber != nil { slotLabel.text = "\(slotNumber! + 1)" } else { slotLabel.text = "" }
            typeLabel.text = effect?.type.rawValue.uppercased() ?? ""
            nameLabel.text = effect?.name?.uppercased() ?? ""
            if effect == nil {
                state = .disabled
            } else {
                state = (effect?.enabled ?? false) ? .on : .off
            }
            knob6.isHidden = effect?.knobs.count ?? 0 < 6
            label6.isHidden = effect?.knobs.count ?? 0 < 6
            knob5.isHidden = effect?.knobs.count ?? 0 < 5
            label5.isHidden = effect?.knobs.count ?? 0 < 5
            knob4.isHidden = effect?.knobs.count ?? 0 < 4
            label4.isHidden = effect?.knobs.count ?? 0 < 4
            knob3.isHidden = effect?.knobs.count ?? 0 < 3
            label3.isHidden = effect?.knobs.count ?? 0 < 3
            knob2.isHidden = effect?.knobs.count ?? 0 < 2
            label2.isHidden = effect?.knobs.count ?? 0 < 2
            knob1.isHidden = effect?.knobs.count ?? 0 < 1
            label1.isHidden = effect?.knobs.count ?? 0 < 1
            
            if effect?.knobs.count ?? 0 > 0 {
                knob1.floatValue = effect?.knobs[0].value ?? 0
                label1.text = effect?.knobs[0].name ?? ""
            }
            if effect?.knobs.count ?? 0 > 1 {
                knob2.floatValue = effect?.knobs[1].value ?? 0
                label2.text = effect?.knobs[1].name ?? ""
            }
            if effect?.knobs.count ?? 0 > 2 {
                knob3.floatValue = effect?.knobs[2].value ?? 0
                label3.text = effect?.knobs[2].name ?? ""
            }
            if effect?.knobs.count ?? 0 > 3 {
                knob4.floatValue = effect?.knobs[3].value ?? 0
                label4.text = effect?.knobs[3].name ?? ""
            }
            if effect?.knobs.count ?? 0 > 4 {
                knob5.floatValue = effect?.knobs[4].value ?? 0
                label5.text = effect?.knobs[4].name ?? ""
            }
            if effect?.knobs.count ?? 0 > 5 {
                knob6.floatValue = effect?.knobs[5].value ?? 0
                label6.text = effect?.knobs[5].name ?? ""
            }
        }
    }
}

extension EffectVC: EffectKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: EffectKnobControl, value: Float) {
        if let slotNumber = slotNumber {
            if effect != nil  {
                switch sender {
                case knob1:
                    ULog.verbose("New knob 1 is %.2f", value)
                    effect!.knobs[0].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                case knob2:
                    ULog.verbose("New knob 2 is %.2f", value)
                    effect!.knobs[1].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                case knob3:
                    ULog.verbose("New knob 3 is %.2f", value)
                    effect!.knobs[2].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                case knob4:
                    ULog.verbose("New knob 4 is %.2f", value)
                    effect!.knobs[3].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                case knob5:
                    ULog.verbose("New knob 5 is %.2f", value)
                    effect!.knobs[4].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                case knob6:
                    ULog.verbose("New knob 6 is %.2f", value)
                    effect!.knobs[5].value = value
                    delegate?.settingsDidChangeForEffect(self, slotNumber: slotNumber, effect: effect!)
                default:
                    ULog.error("Don't know what knob sent this event")
                }
            }
        }
    }
}
