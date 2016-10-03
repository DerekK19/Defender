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

    let verbose = true
    
    fileprivate var powerState: PowerState = .off {
        didSet {
            self.powerButton.powerState = powerState
            self.powerButton.isEnabled = currentAmplifier != nil
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

        configureNotifications()
        configureAmplifiers()

        let contrastColour = NSColor.white
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        if self.view.layer != nil {
            if let image = NSImage(named: "background-texture") {
                let pattern = NSColor(patternImage: image).cgColor
                self.view.layer?.backgroundColor = pattern
            }
        }        
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedDisplay" {
            self.displayVC = segue.destinationController as? DisplayVC
        }
    }
    
    @IBAction func willPowerAmplifier(_ sender: ActionButtonControl) {
        if sender.state == NSOffState {
            DebugPrint(" Powering off")
            self.powerState = .off
        } else {
            DebugPrint(" Powering on")
            sender.state = NSOffState
            if let amplifier = currentAmplifier {
                Mustang().getPresets(amplifier) { (presets) in
                    DispatchQueue.main.async {
                        for preset in presets {
                            self.presets[preset.number] = preset
                        }
                        self.powerState = .on
                        self.valueDidChangeForWheel(self.wheel, value: 0)
                        sender.state = NSOnState
                    }
                }
            }
        }
    }
    
    // MARK: Private Functions
    fileprivate func reset() {
        presets = [UInt8 : DTOPreset] ()
        currentAmplifier = nil
        amplifiers = [DTOAmplifier]()
        powerButton.state = NSOffState
        powerState = .off
    }
    
    fileprivate func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnected), name: NSNotification.Name(rawValue: Mustang.deviceConnectedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOpened), name: NSNotification.Name(rawValue: Mustang.deviceOpenedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceClosed), name: NSNotification.Name(rawValue: Mustang.deviceClosedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: NSNotification.Name(rawValue: Mustang.deviceDisconnectedNotificationName), object: nil)
    }

    @objc fileprivate func deviceConnected() {
        DebugPrint(" Connected")
    }
    
    @objc fileprivate func deviceOpened() {
        DebugPrint(" Opened")
        configureAmplifiers()
    }
    
    @objc fileprivate func deviceClosed() {
        DebugPrint(" Closed")
    }
    
    @objc fileprivate func deviceDisconnected() {
        DebugPrint(" Disconnected")
        DispatchQueue.main.async {
            self.reset()
        }
    }
    
    fileprivate func configureAmplifiers() {
        amplifiers = Mustang().getConnectedAmplifiers()
        DispatchQueue.main.async {
            self.currentAmplifier = self.amplifiers.first
            self.configureAmplifier(self.currentAmplifier)
        }
    }
    
    fileprivate func configureAmplifier(_ amplifier: DTOAmplifier?) {
        powerState = .off
    }
    
    fileprivate func displayPreset(_ value: Int) {
        let preset = presets[UInt8(value)]
        displayPreset(preset)
    }
    
    fileprivate func displayPreset(_ preset: DTOPreset?) {
        if preset != nil { DebugPrint("  Preset \(preset!.number) (\(preset!.name))") }
        if let gain = preset?.gain1 {
            DebugPrint("   Gain: \(gain)")
            gainKnob.floatValue = gain
        } else {
            DebugPrint("   Gain: -unset-")
            gainKnob.floatValue = 1.0
        }
        if let volume = preset?.volume {
            DebugPrint("   Volume: \(volume)")
            volumeKnob.floatValue = volume
        } else {
            DebugPrint("   Volume: -unset-")
            volumeKnob.floatValue = 1.0
        }
        if let treble = preset?.treble {
            DebugPrint("   Treble: \(treble)")
            trebleKnob.floatValue = treble
        } else {
            DebugPrint("   Treble: -unset-")
            trebleKnob.floatValue = 1.0
        }
        if let middle = preset?.middle {
            DebugPrint("   Middle: \(middle)")
            middleKnob.floatValue = middle
        } else {
            DebugPrint("   Middle: -unset-")
            middleKnob.floatValue = 1.0
        }
        if let bass = preset?.bass {
            DebugPrint("   Bass: \(bass)")
            bassKnob.floatValue = bass
        } else {
            DebugPrint("   Bass: -unset-")
            bassKnob.floatValue = 1.0
        }
        if let presence = preset?.presence {
            DebugPrint("   Reverb/Presence: \(presence)")
            reverbKnob.floatValue = presence
        } else {
            DebugPrint("   Reverb/Presence: -unset-")
            reverbKnob.floatValue = 1.0
        }
        DebugPrint("   Model: \(preset?.modelName ?? "-unknown-")")
        DebugPrint("   Cabinet: \(preset?.cabinetName ?? "-unknown-")")
        DebugPrint("    Stomp: \(preset?.stompEffect?.name ?? "-empty-")")
        DebugKnobs(forEffect: preset?.stompEffect)
        DebugPrint("      Mod: \(preset?.modulationEffect?.name ?? "-empty-")")
        DebugKnobs(forEffect: preset?.modulationEffect)
        DebugPrint("    Delay: \(preset?.delayEffect?.name ?? "-empty-")")
        DebugKnobs(forEffect: preset?.delayEffect)
        DebugPrint("   Reverb: \(preset?.reverbEffect?.name ?? "-empty-")")
        DebugKnobs(forEffect: preset?.reverbEffect)
        displayVC?.configureWithPreset(preset)
    }

    // MARK: Debug logging
    internal func DebugPrint(_ text: String) {
        if (verbose) {
            print(text)
        }
    }
    internal func DebugKnobs(forEffect effect: DTOEffect?) {
        if (verbose) {
            print("    Knobs: ", terminator: "")
            effect?.knobs.forEach { print("\(String(format: "%0.2f", $0.value)) ", terminator:"") }
            print("")
        }
    }
}

extension MainVC: KnobDelegate {
    
    func valueDidChangeForKnob(_ sender: KnobControl, value: Float) {
        switch sender {
        case gainKnob:
            DebugPrint("New gain is \(value)")
        case volumeKnob:
            DebugPrint("New volume is \(value)")
        case trebleKnob:
            DebugPrint("New treble is \(value)")
        case middleKnob:
            DebugPrint("New middle is \(value)")
        case bassKnob:
            DebugPrint("New bass is \(value)")
        case reverbKnob:
            DebugPrint("New reverb is \(value)")
        default:
            NSLog("Don't know what knob sent this event")
        }
        saveButton.setState(.warning)
        exitButton.setState(.warning)
    }
}

extension MainVC: WheelDelegate {
    
    func valueIsChangingForWheel(_ sender: WheelControl, value: Int) {
        switch sender {
        case wheel:
            //DebugPrint("Wheel value is changing to \(value)")
            displayPreset(value)
        default:
            NSLog("Don't know what wheel sent this event")
        }
    }
    
    func valueDidChangeForWheel(_ sender: WheelControl, value: Int) {
        switch sender {
        case wheel:
            //DebugPrint("Wheel value changed to \(value)")
            saveButton.setState(.active)
            exitButton.setState(.active)
            if value >= 0 && value < presets.count {
                if let preset = presets[UInt8(value)],  let _ = preset.gain1 {
                    displayPreset(preset)
                } else {
                    if let amplifier = currentAmplifier {
                        Mustang().getPreset(
                            amplifier,
                            preset: UInt8(value)) { (preset) in
                                DispatchQueue.main.async {
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

