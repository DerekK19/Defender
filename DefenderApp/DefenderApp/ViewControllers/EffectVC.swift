//
//  EffectVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class EffectVC: UIViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var shade: ShadeControl!
    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var chassis: EffectControl!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var powerLED: LEDControl!

    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0),
                                      2 : UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0),
                                      10 : UIColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0),
                                      14 : UIColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)]
    
    var fullBackgroundColour = UIColor.black
    var effectBackgroundColour = UIColor.black
    
    var slotNumber: Int?
    var effect: DXEffect?
    
    var appeared = false
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = UIColor()
            switch state {
            case .disabled:
                newBackgroundColour = UIColor.slotBackground
                slotLabel.isHidden = false
                self.powerLED.backgroundColour = UIColor.slotBackground
            case .off:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                self.powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                self.powerLED.backgroundColour = UIColor.red
            }
            self.effectBackgroundColour = newBackgroundColour
            self.chassis.backgroundColour = newBackgroundColour
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
        self.configureWith(effect: self.effect)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(effect: DXEffect?) {
        self.effect = effect
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? UIColor.slotBackground
        if appeared {
            if slotNumber != nil { slotLabel.text = "\(self.slotNumber! + 1)" } else { slotLabel.text = "" }
            typeLabel.text = effect?.type.rawValue.uppercased() ?? ""
            nameLabel.text = effect?.name?.uppercased() ?? ""
            if effect == nil {
                state = .disabled
            } else {
                state = (effect?.enabled ?? false) ? .on : .off
            }
        }
    }
}
