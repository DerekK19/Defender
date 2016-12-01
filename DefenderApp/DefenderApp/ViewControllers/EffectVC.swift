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
    @IBOutlet weak var chassis: EffectControl!
    @IBOutlet weak var shade: ShadeControl!

    let slotBackgroundColour = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
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
            //            self.pedalLogo.alpha = state == .disabled ? 0.0 : 1.0
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
//                self.powerLED.backgroundColour = UIColor.black
            case .off:
                newBackgroundColour = fullBackgroundColour
//                self.powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
//                self.powerLED.backgroundColour = UIColor.red
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.powerState = .on
        self.state = .disabled
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("Appearing slot \(effect?.slot) \(fullBackgroundColour)")
        appeared = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(effect: DXEffect?) {
        self.effect = effect
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? slotBackgroundColour
        if appeared {
            if effect == nil {
                state = .disabled
            } else {
                state = (effect?.enabled ?? false) ? .on : .off
            }
        }
    }
}
