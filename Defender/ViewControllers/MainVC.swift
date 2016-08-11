//
//  ViewController.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class MainVC: NSViewController {

    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var powerButton: ActionButtonControl!
    @IBOutlet weak var gainArrow: NSImageView!
    @IBOutlet weak var volumeArrow: NSImageView!
    @IBOutlet weak var trebleArrow: NSImageView!
    @IBOutlet weak var middleArrow: NSImageView!
    @IBOutlet weak var bassArrow: NSImageView!
    @IBOutlet weak var reverbArrow: NSImageView!
    @IBOutlet weak var gainLabel: NSTextField!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var trebleLabel: NSTextField!
    @IBOutlet weak var middleLabel: NSTextField!
    @IBOutlet weak var bassLabel: NSTextField!
    @IBOutlet weak var reverbLabel: NSTextField!
    @IBOutlet weak var gainKnob: KnobControl!
    @IBOutlet weak var volumeKnob: KnobControl!
    @IBOutlet weak var trebleKnob: KnobControl!
    @IBOutlet weak var middleKnob: KnobControl!
    @IBOutlet weak var bassKnob: KnobControl!
    @IBOutlet weak var reverbKnob: KnobControl!
    @IBOutlet weak var wheel: WheelControl!
    @IBOutlet weak var utilButton: ActionButtonControl!
    @IBOutlet weak var saveButton: ActionButtonControl!
    @IBOutlet weak var exitButton: ActionButtonControl!
    @IBOutlet weak var tapButton: ActionButtonControl!

    @IBOutlet weak var displayVC: DisplayVC?
    
    var amplifiers = [DTOAmplifier]()
    var currentAmplifier: DTOAmplifier?
    var presets = [UInt8 : DTOPreset] ()
    
    private var powerState: PowerState = .Off {
        didSet {
            self.powerButton.powerState = powerState
            self.powerButton.enabled = true // currentAmplifier != nil
            self.utilButton.powerState = powerState
            self.saveButton.powerState = powerState
            self.exitButton.powerState = powerState
            self.tapButton.powerState = powerState
            self.wheel.powerState = powerState
            self.displayVC?.powerState = powerState
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true

        // Do any additional setup after loading the view.

        configureAmplifiers()

        let contrastColour = NSColor.whiteColor()
        gainArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        volumeArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        trebleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        middleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        bassArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        reverbArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        gainLabel.textColor = contrastColour
        volumeLabel.textColor = contrastColour
        trebleLabel.textColor = contrastColour
        middleLabel.textColor = contrastColour
        bassLabel.textColor = contrastColour
        reverbLabel.textColor = contrastColour
        
        gainKnob.delegate = self
        volumeKnob.delegate = self
        trebleKnob.delegate = self
        middleKnob.delegate = self
        bassKnob.delegate = self
        reverbKnob.delegate = self
        wheel.delegate = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        if self.view.layer != nil {
            if let image = NSImage(named: "background-texture") {
                let pattern = NSColor(patternImage: image).CGColor
                self.view.layer?.backgroundColor = pattern
            }
        }        
    }

    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedDisplay" {
            self.displayVC = segue.destinationController as? DisplayVC
        }
    }
    
    @IBAction func willPowerAmplifier(sender: ActionButtonControl) {
        if sender.state == NSOffState {
            NSLog("Going off")
            self.powerState = .Off
        } else {
            NSLog("Going on")
//            sender.state = NSOffState
/* TEMP */            self.powerState = .On
/* TEMP */            sender.state = NSOnState

            if let amplifier = currentAmplifier {
                Mustang().getPresets(amplifier) { (presets) in
                    dispatch_async(dispatch_get_main_queue()) {
                        for preset in presets {
                            self.presets[preset.number] = preset
                        }
                        self.valueDidChangeForWheel(self.wheel, value: 0)
                        sender.state = NSOnState
                        self.powerState = .On
                    }
                }
            }
        }
    }
    
    // MARK: Private Functions
    private func configureAmplifiers() {
        amplifiers = Mustang().getConnectedAmplifiers()
        currentAmplifier = amplifiers.first
        configureAmplifier(currentAmplifier)
    }
    
    private func configureAmplifier(amplifier: DTOAmplifier?) {
        powerState = .Off
    }
    
    private func displayPreset(value: Int) {
        let preset = presets[UInt8(value)]
        displayPreset(preset)
    }
    
    private func displayPreset(preset: DTOPreset?) {
        if let gain = preset?.gain1 {
            NSLog("Gain: \(gain)")
            gainKnob.floatValue = gain
        } else {
            gainKnob.floatValue = 1.0
        }
        if let volume = preset?.volume {
            NSLog("Volume: \(volume)")
            volumeKnob.floatValue = volume
        } else {
            volumeKnob.floatValue = 1.0
        }
        if let treble = preset?.treble {
            NSLog("Treble: \(treble)")
            trebleKnob.floatValue = treble
        } else {
            trebleKnob.floatValue = 1.0
        }
        if let middle = preset?.middle {
            NSLog("Middle: \(middle)")
            middleKnob.floatValue = middle
        } else {
            middleKnob.floatValue = 1.0
        }
        if let bass = preset?.bass {
            NSLog("Bass: \(bass)")
            bassKnob.floatValue = bass
        } else {
            bassKnob.floatValue = 1.0
        }
        if let presence = preset?.presence {
            NSLog("Reverb/Presence: \(presence)")
            reverbKnob.floatValue = presence
        } else {
            reverbKnob.floatValue = 1.0
        }
        displayVC?.configureWithPreset(preset)
    }
}

extension MainVC: KnobDelegate {
    
    func valueDidChangeForKnob(sender: KnobControl, value: Float) {
        switch sender {
        case gainKnob:
            NSLog("New gain is \(value)")
        case volumeKnob:
            NSLog("New volume is \(value)")
        case trebleKnob:
            NSLog("New treble is \(value)")
        case middleKnob:
            NSLog("New middle is \(value)")
        case bassKnob:
            NSLog("New bass is \(value)")
        case reverbKnob:
            NSLog("New reverb is \(value)")
        default:
            NSLog("Don't know what knob sent this event")
        }
        saveButton.setState(.Warning)
        exitButton.setState(.Warning)
    }
}

extension MainVC: WheelDelegate {
    
    func valueIsChangingForWheel(sender: WheelControl, value: Int) {
        switch sender {
        case wheel:
            NSLog("Wheel value is changing to \(value)")
            displayPreset(value)
        default:
            NSLog("Don't know what wheel sent this event")
        }
    }
    
    func valueDidChangeForWheel(sender: WheelControl, value: Int) {
        switch sender {
        case wheel:
            NSLog("Wheel value changed to \(value)")
            saveButton.setState(.Active)
            exitButton.setState(.Active)
            if value >= 0 && value < presets.count {
                if let preset = presets[UInt8(value)],  _ = preset.gain1 {
                    displayPreset(preset)
                } else {
                    if let amplifier = currentAmplifier {
                        Mustang().getPreset(
                            amplifier,
                            preset: UInt8(value)) { (preset) in
                                dispatch_async(dispatch_get_main_queue()) {
                                    if let preset = preset {
                                        self.presets[preset.number] = preset
                                        if let _ = preset.gain1 {
                                            self.displayPreset(preset)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        default:
            NSLog("Don't know what wheel sent this event")
        }
    }
}

