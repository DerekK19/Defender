//
//  BaseEffectVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 5/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class BaseEffectVC: UIViewController {
    
    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var shade: ShadeControl!

    var appeared = false
    
    internal var powerState: PowerState = .off {
        didSet {
            if appeared {
                self.shade.state = powerState == .on ? .open : .closed
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appeared = true
        let currentPowerState = powerState
        powerState = currentPowerState
    }    
}
