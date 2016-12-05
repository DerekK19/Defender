//
//  ControlsVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger

protocol ControlsVCDelegate {
    func settingsDidChangeForControls(_ sender: ControlsVC, preset: DXPreset?)
}

class ControlsVC: BaseEffectVC {
    
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
    
    var delegate: ControlsVCDelegate?
    
    var preset: DXPreset?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func configureWith(preset: DXPreset?) {
        self.preset = preset
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
            Flogger.log.verbose("New gain is \(value)")
            preset?.gain1 = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        case volumeKnob:
            Flogger.log.verbose("New volume is \(value)")
            preset?.volume = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        case trebleKnob:
            Flogger.log.verbose("New treble is \(value)")
            preset?.treble = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        case middleKnob:
            Flogger.log.verbose("New middle is \(value)")
            preset?.middle = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        case bassKnob:
            Flogger.log.verbose("New bass is \(value)")
            preset?.bass = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        case presenceKnob:
            Flogger.log.verbose("New presence is \(value)")
            preset?.presence = value
            delegate?.settingsDidChangeForControls(self, preset: preset)
        default:
            Flogger.log.error("Don't know what knob sent this event")
        }
    }
}

