//
//  ViewController.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang
import Flogger

class MainVC: NSViewController {

    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var powerButton: ActionButtonControl!
    @IBOutlet weak var statusLED: LEDControl!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var bluetoothLogo: NSImageView!
    @IBOutlet weak var txLED: LEDControl!
    @IBOutlet weak var rxLED: LEDControl!
    @IBOutlet weak var bluetoothLabel: NSTextField!
    @IBOutlet weak var gainArrow: NSImageView!
    @IBOutlet weak var volumeArrow: NSImageView!
    @IBOutlet weak var trebleArrow: NSImageView!
    @IBOutlet weak var middleArrow: NSImageView!
    @IBOutlet weak var bassArrow: NSImageView!
    @IBOutlet weak var presenceArrow: NSImageView!
    @IBOutlet weak var gainLabel: NSTextField!
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var trebleLabel: NSTextField!
    @IBOutlet weak var middleLabel: NSTextField!
    @IBOutlet weak var bassLabel: NSTextField!
    @IBOutlet weak var presenceLabel: NSTextField!
    @IBOutlet weak var gainKnob: AmpKnobControl!
    @IBOutlet weak var volumeKnob: AmpKnobControl!
    @IBOutlet weak var trebleKnob: AmpKnobControl!
    @IBOutlet weak var middleKnob: AmpKnobControl!
    @IBOutlet weak var bassKnob: AmpKnobControl!
    @IBOutlet weak var presenceKnob: AmpKnobControl!
    @IBOutlet weak var wheel: WheelControl!
    @IBOutlet weak var utilButton: ActionButtonControl!
    @IBOutlet weak var saveButton: ActionButtonControl!
    @IBOutlet weak var exitButton: ActionButtonControl!
    @IBOutlet weak var tapButton: ActionButtonControl!
    
    @IBOutlet weak var debugButton: NSButton!
    
    @IBOutlet weak var effectsSettings: NSStackView!
    @IBOutlet weak var pedalsArea: NSStackView!
    @IBOutlet weak var effectsArea: NSStackView!
    
    @IBOutlet weak var displayVC: DisplayVC?
    @IBOutlet weak var webVC: WebVC?
    @IBOutlet weak var effect1VC: EffectVC?
    @IBOutlet weak var effect2VC: EffectVC?
    @IBOutlet weak var effect3VC: EffectVC?
    @IBOutlet weak var effect4VC: EffectVC?
    @IBOutlet weak var pedal1VC: PedalVC?
    @IBOutlet weak var pedal2VC: PedalVC?
    @IBOutlet weak var pedal3VC: PedalVC?
    @IBOutlet weak var pedal4VC: PedalVC?
    
    fileprivate var ampManager = AmpManager()
    fileprivate var remoteManager: RemoteManager?

    fileprivate var documentController = NSDocumentController.shared()
    
    var currentPreset: DTOPreset?
    
    let verbose = true
    var debuggingConstraints = false
    
    fileprivate var powerState: PowerState = .off {
        didSet {
            self.powerButton.powerState = powerState
            self.powerButton.isEnabled = ampManager.hasAnAmplifier
            self.utilButton.powerState = powerState
            self.saveButton.powerState = powerState
            self.exitButton.powerState = powerState
            self.tapButton.powerState = powerState
            self.wheel.powerState = powerState
            self.displayVC?.powerState = powerState
            self.effect1VC?.powerState = powerState
            self.effect2VC?.powerState = powerState
            self.effect3VC?.powerState = powerState
            self.effect4VC?.powerState = powerState
            self.pedal1VC?.powerState = powerState
            self.pedal2VC?.powerState = powerState
            self.pedal3VC?.powerState = powerState
            self.pedal4VC?.powerState = powerState
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true

        bluetoothLogo.isHidden = true
        bluetoothLabel.isHidden = true
        txLED.backgroundColour = NSColor.clear
        rxLED.backgroundColour = NSColor.clear
        
        if let appDelegate = NSApplication.shared().delegate as? AppDelegate {
            remoteManager = appDelegate.remoteManager
            remoteManager?.delegate = self
        }

        reset()
        
        configureAmplifiers()

        debugButton.isHidden = !ampManager.mocking
        
        let contrastColour = NSColor.white
        gainArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        volumeArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        trebleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        middleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        bassArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        presenceArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
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
        wheel.delegate = self
        
    }
    
    override func viewWillAppear() {
        remoteManager?.start()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        if let appView = self.view as? AppViewControl {
            if let image = NSImage(named: "background-texture") {
                appView.backgroundColour = NSColor(patternImage: image)
            }
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedDisplay":
                self.displayVC = segue.destinationController as? DisplayVC
            case "embedWeb":
                self.webVC = segue.destinationController as? WebVC
                self.webVC?.ampManager = self.ampManager
                self.webVC?.delegate = self

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
    
    // MARK: Public functions
    func willImportPresetFromXml(_ xml: XMLDocument) {
        if let preset = ampManager.importPreset(xml) {
            DispatchQueue.main.async {
                var newPreset = preset
                newPreset.number = self.currentPreset?.number
                self.setPreset(newPreset)
                self.saveButton.setState(.warning)
            }
        }
    }
    
    func exportPresetAsXml() -> XMLDocument? {
        if let currentPreset = currentPreset {
            return ampManager.exportPresetAsXml(currentPreset)
        }
        return nil
    }
    
    // MARK: Action functions
    
    @IBAction func willPowerAmplifier(_ sender: ActionButtonControl) {
        if !ampManager.hasAnAmplifier { return }
        if sender.state == NSOffState {
            Flogger.log.debug(" Powering off")
            self.powerState = .off
            self.setPreset(nil)
        } else {
            Flogger.log.debug(" Powering on")
            sender.state = NSOffState
            ampManager.getPresets() {
                DispatchQueue.main.async {
                    self.powerState = .on
                    self.valueDidChangeForWheel(self.wheel, value: 0)
                    sender.state = NSOnState
                }
            }
        }
    }
    
    @IBAction func willSave(_ sender: ActionButtonControl) {
        if sender.powerState == .on {
            if let currentPreset = currentPreset {
                if sender.currentState == .warning {
                    Flogger.log.debug(" Saving effect")
                    exitButton.setState(.active)
                    ampManager.setPreset(currentPreset, onCompletion: { (preset) in
                        self.saveButton.setState(.ok)
                        self.displayVC?.setState(.edit)
                    })
                }
                else if sender.currentState == .ok {
                    Flogger.log.debug(" Confirming effect")
                    ampManager.savePreset(currentPreset) { (saved) in
                        self.ampManager.resetPreset(self.wheel.intValue) { (preset) in
                            DispatchQueue.main.async {
                                self.displayPreset(preset)
                                self.saveButton.setState(.active)
                                self.displayVC?.setState(.view)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func willExit(_ sender: ActionButtonControl) {
        if sender.powerState == .on {
            Flogger.log.debug(" Cancelling save")
            saveButton.setState(.active)
            exitButton.setState(.ok)
            ampManager.resetPreset(self.wheel.intValue) { (preset) in
                DispatchQueue.main.async {
                    self.displayPreset(preset)
                    self.exitButton.setState(.active)
                    self.displayVC?.setState(.view)
                }
            }
        }
    }
    
    @IBAction func willDebug(_ sender: NSButton) {
        debuggingConstraints = !debuggingConstraints
        if debuggingConstraints {
            var debugConstraints = [NSLayoutConstraint]()
            debugConstraints.append(contentsOf: self.view.constraints)
            debugConstraints.append(contentsOf: self.effectsSettings.constraints)
            debugConstraints.append(contentsOf: self.effectsArea.constraints)
            debugConstraints.append(contentsOf: self.pedalsArea.constraints)
            self.view.window?.visualizeConstraints(debugConstraints)
        } else {
            self.view.window?.visualizeConstraints([NSLayoutConstraint]())
        }
    }
    
    // MARK: Private Functions
    fileprivate func reset() {
        statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
        statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
        bluetoothLabel.stringValue = ""
        statusLabel.textColor = .white
        bluetoothLabel.textColor = .white
        powerButton.state = NSOffState
        powerState = .off
    }
    
    fileprivate func setPreset(_ preset: DTOPreset?) {
        currentPreset = preset
        displayPreset(preset)
        sendCurrentPreset()
    }
    
    fileprivate func configureAmplifiers() {
        ampManager = AmpManager()
        ampManager.delegate = self
        DispatchQueue.main.async {
            self.configureAmplifier()
        }
    }
    
    fileprivate func configureAmplifier() {
        powerState = .off
    }
    
    fileprivate func displayPreset(_ value: Int) {
        ampManager.getCachedPreset(value) { (preset) in
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

        gainKnob.floatValue = preset?.gain1 ?? 1.0
        volumeKnob.floatValue = preset?.volume ?? 1.0
        trebleKnob.floatValue = preset?.treble ?? 1.0
        middleKnob.floatValue = preset?.middle ?? 1.0
        bassKnob.floatValue = preset?.bass ?? 1.0
        presenceKnob.floatValue = preset?.presence ?? 1.0

        displayVC?.configureWithPreset(preset)
        for effect in preset?.effects ?? [DTOEffect]() {
            displayEffect(effect)
        }
    }

    private func displayEffect(_ effect: DTOEffect?) {
        switch effect?.slot ?? -1 {
        case 0:
            pedal1VC?.configureWithPedal(effect)
            pedal1VC?.delegate = self
        case 1:
            pedal2VC?.configureWithPedal(effect)
            pedal2VC?.delegate = self
        case 2:
            pedal3VC?.configureWithPedal(effect)
            pedal3VC?.delegate = self
        case 3:
            pedal4VC?.configureWithPedal(effect)
            pedal4VC?.delegate = self
        case 4:
            effect1VC?.configureWithEffect(effect)
            effect1VC?.delegate = self
        case 5:
            effect2VC?.configureWithEffect(effect)
            effect2VC?.delegate = self
        case 6:
            effect3VC?.configureWithEffect(effect)
            effect3VC?.delegate = self
        case 7:
            effect4VC?.configureWithEffect(effect)
            effect4VC?.delegate = self
        default:
            break
        }
    }
    
    func sendCurrentAmplifier() {
        var message: DXMessage!
        if let amp = self.ampManager.currentAmplifier {
            message = DXMessage(command: .amplifier, data: DXAmplifier(dto: amp))
        } else {
            message = DXMessage(command: .amplifier, data: DXAmplifier(name: "No amplifier", manufacturer: ""))
        }
        sendMessage(message)
    }
    
    func sendCurrentPreset() {
        var message: DXMessage!
        if let preset = self.currentPreset {
            message = DXMessage(command: .preset, data: DXPreset(dto: preset))
        } else {
            message = DXMessage(command: .preset, data: DXPreset(name: ""))
        }
        sendMessage(message)
    }
    
    func sendMessage(_ message: DXMessage) {
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = NSColor.red
//            bluetoothLabel.stringValue = "Sending"
        } else {
            Flogger.log.error("Failed to send message. Command = \(message.command)")
        }
    }
    
    // MARK: Debug logging
    internal func DebugPreset(_ preset: DTOPreset?) {
        if verbose {
            var text = ""
            if let number = preset?.number {
                text += "  Preset \(number)"
            } else {
                text += "  Preset -unknown-"
            }
            text += " - \(preset?.name ?? "-unknown-")\n"
            if let gain = preset?.gain1 {
                text += "   Gain: \(gain)\n"
            } else {
                text += "   Gain: -unset-\n"
            }
            if let volume = preset?.volume {
                text += "   Volume: \(volume)\n"
            } else {
                text += "   Volume: -unset-\n"
            }
            if let treble = preset?.treble {
                text += "   Treble: \(treble)\n"
            } else {
                text += "   Treble: -unset-\n"
            }
            if let middle = preset?.middle {
                text += "   Middle: \(middle)\n"
            } else {
                text += "   Middle: -unset-\n"
            }
            if let bass = preset?.bass {
                text += "   Bass: \(bass)\n"
            } else {
                text += "   Bass: -unset-\n"
            }
            if let presence = preset?.presence {
                text += "   Reverb/Presence: \(presence)\n"
            } else {
                text += "   Reverb/Presence: -unset-\n"
            }
            text += "   Model: \(preset?.moduleName ?? "-unknown-")\n"
            text += "   Cabinet: \(preset?.cabinetName ?? "-unknown-")\n"
            for effect in preset?.effects ?? [DTOEffect]() {
                text += "   \(effect.type.rawValue): \(effect.name ?? "-empty-") - \(effect.enabled ? "ON" : "OFF")\n"
                text += "    Knobs: \(effect.knobCount) - "
                effect.knobs.forEach { text += "\(String(format: "%0.2f", $0.value)) " }
                text += "slot \(effect.slot) (\(effect.aValue1) \(effect.aValue2) \(effect.aValue3))\n"
            }
            Flogger.log.info(text)
        }
    }
    
}

extension MainVC: AmpKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: AmpKnobControl, value: Float) {
        switch sender {
        case gainKnob:
            Flogger.log.debug("New gain is \(value)")
            currentPreset?.gain1 = value
        case volumeKnob:
            Flogger.log.debug("New volume is \(value)")
            currentPreset?.volume = value
        case trebleKnob:
            Flogger.log.debug("New treble is \(value)")
            currentPreset?.treble = value
        case middleKnob:
            Flogger.log.debug("New middle is \(value)")
            currentPreset?.middle = value
        case bassKnob:
            Flogger.log.debug("New bass is \(value)")
            currentPreset?.bass = value
        case presenceKnob:
            Flogger.log.debug("New presence is \(value)")
            currentPreset?.presence = value
        default:
            Flogger.log.error("Don't know what knob sent this event")
        }
        saveButton.setState(.warning)
        exitButton.setState(.warning)
    }
}

extension MainVC: PedalVCDelegate {
    
    func settingsDidChangeForPedal(_ sender: PedalVC) {
        if sender == pedal1VC {
            Flogger.log.debug("New settings for pedal 1")
        }
        else if sender == pedal2VC {
            Flogger.log.debug("New settings for pedal 2")
        }
        else if sender == pedal3VC {
            Flogger.log.debug("New settings for pedal 3")
        }
        else if sender == pedal4VC {
            Flogger.log.debug("New settings for pedal 4")
        }
        else {
            Flogger.log.error("Don't know what pedal sent this event")
        }
        saveButton.setState(.warning)
        exitButton.setState(.warning)
    }
}

extension MainVC: EffectVCDelegate {
    
    func settingsDidChangeForEffect(_ sender: EffectVC) {
        if sender == effect1VC {
            Flogger.log.debug("New settings for effect 1")
        }
        else if sender == effect2VC {
            Flogger.log.debug("New settings for effect 2")
        }
        else if sender == effect3VC {
            Flogger.log.debug("New settings for effect 3")
        }
        else if sender == effect4VC {
            Flogger.log.debug("New settings for effect 4")
        }
        else {
            Flogger.log.error("Don't know what effect sent this event")
        }
        saveButton.setState(.warning)
        exitButton.setState(.warning)
    }
}

extension MainVC: WheelDelegate {
    
    func valueIsChangingForWheel(_ sender: WheelControl, value: Int) {
        switch saveButton.currentState {
        case .active:
            switch sender {
            case wheel:
                //Flogger.log.debug("Wheel value is changing to \(value)")
                displayPreset(value)
            default:
                Flogger.log.error("Don't know what wheel sent this event")
            }
        case .warning:
            currentPreset?.number = UInt8(value)
            displayPreset(currentPreset)
            break
        case .ok:
            break
        }
    }
    
    func valueDidChangeForWheel(_ sender: WheelControl, value: Int) {
        switch saveButton.currentState {
        case .active:
            switch sender {
            case wheel:
                //Flogger.log.debug("Wheel value changed to \(value)")
                saveButton.setState(.active)
                exitButton.setState(.active)
                ampManager.getPreset(value) { (preset) in
                    DispatchQueue.main.async {
                        self.setPreset(preset)
                        self.DebugPreset(self.currentPreset)
                    }
                }
            default:
                Flogger.log.error("Don't know what wheel sent this event")
            }
        case .warning:
            DebugPreset(currentPreset)
            break
        case .ok:
            break
        }
    }
}

extension MainVC: AmpManagerDelegate {
    
    func deviceConnected(ampManager: AmpManager) {
        Flogger.log.debug(" Connected")
        sendCurrentAmplifier()
        DispatchQueue.main.async {
            self.statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
            self.statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
        }
    }
    
    func deviceOpened(ampManager: AmpManager) {
        Flogger.log.debug(" Opened")
        configureAmplifiers()
        sendCurrentPreset()
    }
    
    func deviceClosed(ampManager: AmpManager) {
        Flogger.log.debug(" Closed")
        setPreset(nil)
    }
    
    func deviceDisconnected(ampManager: AmpManager) {
        Flogger.log.debug(" Disconnected")
        DispatchQueue.main.async {
            self.reset()
            self.setPreset(nil)
            self.sendCurrentAmplifier()
            self.statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
            self.statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
        }
    }
}

extension MainVC: WebVCDelegate {
    
    func didSelectPreset(preset: DTOPreset?) {
        var newPreset = preset
        if let _ = newPreset {
            newPreset!.number = currentPreset?.number
        }
        self.setPreset(newPreset)
        saveButton.setState(.warning)
    }
}

extension MainVC: RemoteManagerDelegate {
    func remoteManagerDidStart(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.isHidden = false
            self.bluetoothLogo.alphaValue = 0.5
            self.bluetoothLabel.isHidden = false
//            self.bluetoothLabel.stringValue = "Started"
        }
    }
    
    func remoteManagerDidConnect(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.alphaValue = 1.0
//            self.bluetoothLabel.stringValue = "Connected"
        }
    }

    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        DispatchQueue.main.async {
            self.txLED.backgroundColour = NSColor.clear
//            self.bluetoothLabel.stringValue = "Sent"
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        DispatchQueue.main.async {
            self.rxLED.backgroundColour = NSColor.green
//            self.bluetoothLabel.stringValue = "Received"
            DispatchQueue.main.async {
                do {
                    let message = try DXMessage(data: data)
                    switch message.command as RequestType {
                    case .amplifier:
                        self.sendCurrentAmplifier()
                    case .preset:
                        if message.content == nil {
                            self.sendCurrentPreset()
                        } else {
                            let preset = try DXPreset(data: message.content)
                            if let number = preset.number {
                                self.ampManager.getPreset(Int(number)) { (preset) in
                                    DispatchQueue.main.async {
                                        self.setPreset(preset)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    Flogger.log.error("Receive Failure: Couldn't decode DXMessage or DXPreset")
                }
                self.rxLED.backgroundColour = NSColor.clear
            }
        }
    }
    
    func remoteManagerDidDisconnect(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.alphaValue = 0.5
//            self.bluetoothLabel.stringValue = "Disconnected"
        }
    }

    func remoteManagerDidStop(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.isHidden = true
            self.bluetoothLabel.isHidden = true
        }
    }

}
