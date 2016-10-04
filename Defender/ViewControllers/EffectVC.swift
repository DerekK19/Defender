//
//  EffectVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class EffectVC: NSViewController {

    @IBOutlet weak var effect: EffectControl!

    var effectBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
    var effectForegroundColour = NSColor(red: 0.3, green: 0.38, blue: 0.6, alpha: 1.0)

    var enabledState: EnabledState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            if enabledState == .disabled {
                newBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            } else {
                newBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
            }
            self.effectBackgroundColour = newBackgroundColour
            self.effect.backgroundColour = newBackgroundColour
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            if enabledState == .enabled {
                var newBackgroundColour = NSColor()
                if powerState == .off {
                    newBackgroundColour = NSColor(red: 0.31, green: 0.39, blue: 0.44, alpha: 1.0)
                } else {
                    newBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
                }
                self.effectBackgroundColour = newBackgroundColour
                self.effect.backgroundColour = newBackgroundColour
            }
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
        self.enabledState = .disabled
        self.powerState = .off
    }
    
    func configureWithEffect(_ effect: DTOEffect?) {
        if effect != nil {
            enabledState = .enabled
        } else {
            enabledState = .disabled
        }
    }
    
}
