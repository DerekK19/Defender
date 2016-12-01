//
//  ControlsVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger

class ControlsVC: UIViewController {
    
    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var shade: ShadeControl!
    @IBOutlet weak var gainArrow: UIImageView!
    @IBOutlet weak var volumeArrow: UIImageView!
    @IBOutlet weak var trebleArrow: UIImageView!
    @IBOutlet weak var middleArrow: UIImageView!
    @IBOutlet weak var bassArrow: UIImageView!
    @IBOutlet weak var presenceArrow: UIImageView!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var trebleLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bassLabel: UILabel!
    @IBOutlet weak var presenceLabel: UILabel!
    @IBOutlet weak var gainKnob: AmpKnobControl!
    @IBOutlet weak var volumeKnob: AmpKnobControl!
    @IBOutlet weak var trebleKnob: AmpKnobControl!
    @IBOutlet weak var middleKnob: AmpKnobControl!
    @IBOutlet weak var bassKnob: AmpKnobControl!
    @IBOutlet weak var presenceKnob: AmpKnobControl!
    
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
        
        self.powerState = .off

        let contrastColour = UIColor.white
        gainArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        volumeArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        trebleArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        middleArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        bassArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        presenceArrow.image = UIImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        gainLabel.textColor = contrastColour
        volumeLabel.textColor = contrastColour
        trebleLabel.textColor = contrastColour
        middleLabel.textColor = contrastColour
        bassLabel.textColor = contrastColour
        presenceLabel.textColor = contrastColour
        
        gainKnob.delegate = self
        volumeKnob.delegate = self
        trebleKnob.delegate = self
        middleKnob.delegate = self
        bassKnob.delegate = self
        presenceKnob.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appeared = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func configureWith(preset: DXPreset?) {
        gainKnob.floatValue = preset?.gain1 ?? 1.0
        volumeKnob.floatValue = preset?.volume ?? 1.0
        trebleKnob.floatValue = preset?.treble ?? 1.0
        middleKnob.floatValue = preset?.middle ?? 1.0
        bassKnob.floatValue = preset?.bass ?? 1.0
        presenceKnob.floatValue = preset?.presence ?? 1.0
    }
    
}

extension ControlsVC: AmpKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: AmpKnobControl, value: Float) {
        switch sender {
        case gainKnob:
            Flogger.log.debug("New gain is \(value)")
//            currentPreset?.gain1 = value
        case volumeKnob:
            Flogger.log.debug("New volume is \(value)")
//            currentPreset?.volume = value
        case trebleKnob:
            Flogger.log.debug("New treble is \(value)")
//            currentPreset?.treble = value
        case middleKnob:
            Flogger.log.debug("New middle is \(value)")
//            currentPreset?.middle = value
        case bassKnob:
            Flogger.log.debug("New bass is \(value)")
//            currentPreset?.bass = value
        case presenceKnob:
            Flogger.log.debug("New presence is \(value)")
//            currentPreset?.presence = value
        default:
            Flogger.log.error("Don't know what knob sent this event")
        }
//        saveButton.setState(.warning)
//        exitButton.setState(.warning)
    }
}

