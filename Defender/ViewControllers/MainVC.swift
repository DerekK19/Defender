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
    @IBOutlet weak var effect1VC: EffectVC?
    @IBOutlet weak var effect2VC: EffectVC?
    @IBOutlet weak var effect3VC: EffectVC?
    @IBOutlet weak var effect4VC: EffectVC?
    @IBOutlet weak var pedal1VC: PedalVC?
    @IBOutlet weak var pedal2VC: PedalVC?
    @IBOutlet weak var pedal3VC: PedalVC?
    @IBOutlet weak var pedal4VC: PedalVC?
    
    fileprivate var ampController: AmpController!
    
    let verbose = true
    
    fileprivate var powerState: PowerState = .off {
        didSet {
            self.powerButton.powerState = powerState
            self.powerButton.isEnabled = ampController.hasAnAmplifier
            self.utilButton.powerState = powerState
            self.saveButton.powerState = powerState
            self.exitButton.powerState = powerState
            self.tapButton.powerState = powerState
            self.wheel.powerState = powerState
            self.displayVC?.powerState = powerState
//            self.effect1VC?.powerState = powerState
//            self.effect2VC?.powerState = powerState
//            self.effect3VC?.powerState = powerState
//            self.effect4VC?.powerState = powerState
//            self.pedal1VC?.powerState = powerState
//            self.pedal2VC?.powerState = powerState
//            self.pedal3VC?.powerState = powerState
//            self.pedal4VC?.powerState = powerState
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
        if let identifier = segue.identifier {
            switch identifier {
            case "embedDisplay":
                self.displayVC = segue.destinationController as? DisplayVC
            case "embedEffect1":
                self.effect1VC = segue.destinationController as? EffectVC
            case "embedEffect2":
                self.effect2VC = segue.destinationController as? EffectVC
            case "embedEffect3":
                self.effect3VC = segue.destinationController as? EffectVC
            case "embedEffect4":
                self.effect4VC = segue.destinationController as? EffectVC
            case "embedPedal1":
                self.pedal1VC = segue.destinationController as? PedalVC
            case "embedPedal2":
                self.pedal2VC = segue.destinationController as? PedalVC
            case "embedPedal3":
                self.pedal3VC = segue.destinationController as? PedalVC
            case "embedPedal4":
                self.pedal4VC = segue.destinationController as? PedalVC
            default: break
            }
        }
    }
    
    @IBAction func willPowerAmplifier(_ sender: ActionButtonControl) {
        if sender.state == NSOffState {
            DebugPrint(" Powering off")
            self.powerState = .off
        } else {
            DebugPrint(" Powering on")
            sender.state = NSOffState
            ampController.getPresets() {
                DispatchQueue.main.async {
                    self.powerState = .on
                    self.valueDidChangeForWheel(self.wheel, value: 0)
                    sender.state = NSOnState
                }
            }
        }
    }
    
    // MARK: Private Functions
    fileprivate func reset() {
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
        ampController = AmpController()
        DispatchQueue.main.async {
            self.configureAmplifier()
        }
    }
    
    fileprivate func configureAmplifier() {
        powerState = .off
    }
    
    fileprivate func displayPreset(_ value: Int) {
        ampController.getCachedPreset(value) { (preset) in
            self.displayPreset(preset)
        }
    }
    
    fileprivate func displayPreset(_ preset: DTOPreset?) {
        
        pedal1VC?.configureWithPedal(nil)
        pedal2VC?.configureWithPedal(nil)
        pedal3VC?.configureWithPedal(nil)
        pedal4VC?.configureWithPedal(nil)
        effect1VC?.configureWithEffect(nil)
        effect2VC?.configureWithEffect(nil)
        effect3VC?.configureWithEffect(nil)
        effect4VC?.configureWithEffect(nil)

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
        for effect in preset?.effects ?? [DTOEffect]() {
            DebugPrint("    \(effect.type.rawValue): \(effect.name ?? "-empty-") - \(effect.enabled ? "ON" : "OFF")")
            DebugKnobs(forEffect: effect)
        }
        displayVC?.configureWithPreset(preset)
        for effect in preset?.effects ?? [DTOEffect]() {
            displayEffect(effect)
        }
    }

    private func displayEffect(_ effect: DTOEffect?) {
        switch effect?.slot ?? -1 {
        case 0:
            pedal1VC?.configureWithPedal(effect)
        case 1:
            pedal2VC?.configureWithPedal(effect)
        case 2:
            pedal3VC?.configureWithPedal(effect)
        case 3:
            pedal4VC?.configureWithPedal(effect)
        case 4:
            effect1VC?.configureWithEffect(effect)
        case 5:
            effect2VC?.configureWithEffect(effect)
        case 6:
            effect3VC?.configureWithEffect(effect)
        case 7:
            effect4VC?.configureWithEffect(effect)
        default:
            break
        }
    }
    
    // MARK: Debug logging
    internal func DebugPrint(_ text: String) {
        if (verbose) {
            print(text)
        }
    }
    internal func DebugKnobs(forEffect effect: DTOEffect?) {
        if (verbose) {
            print("    Knobs: \(effect?.knobCount ?? 0) - ", terminator: "")
            effect?.knobs.forEach { print("\(String(format: "%0.2f", $0.value)) ", terminator:"") }
            if let effect = effect { print("slot \(effect.slot) (\(effect.aValue1) \(effect.aValue2) \(effect.aValue3))") }
            else { print("") }
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
            ampController.getPreset(value) { (preset) in
                DispatchQueue.main.async {
                    self.displayPreset(preset)
                }
            }
        default:
            NSLog("Don't know what wheel sent this event")
        }
    }
}

