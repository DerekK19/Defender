//
//  ViewController.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
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
    @IBOutlet weak var presetsLabel: NSTextField!
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
    @IBOutlet weak var effectsLoopLabel: NSTextField!
    @IBOutlet weak var effectsLoopArrow1: NSImageView!
    @IBOutlet weak var effectsLoopArrow2: NSImageView!
    
    @IBOutlet weak var debugButton: NSButton!
    @IBOutlet weak var preloadButton: NSButton!
    
    @IBOutlet weak var effectsSettings: NSStackView!
    @IBOutlet weak var pedalLeads: NSBox!
    @IBOutlet weak var effectLeads: NSBox!
    @IBOutlet weak var pedalsArea: NSStackView!
    @IBOutlet weak var effectsArea: NSStackView!
    
    @IBOutlet weak var displayVC: DisplayVC?
    @IBOutlet weak var webVC: WebVC?
    @IBOutlet weak var cabinetVC: CabinetVC?
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
    
    var currentPreset: BOPreset?
    
    let verbose = true
    var debuggingConstraints = false
    
    fileprivate var powerState: PowerState = .off {
        didSet {
            powerButton.powerState = powerState
            powerButton.isEnabled = ampManager.hasAnAmplifier
            utilButton.powerState = powerState
            saveButton.powerState = powerState
            exitButton.powerState = powerState
            tapButton.powerState = powerState
            wheel.powerState = powerState
            displayVC?.powerState = powerState
            cabinetVC?.powerState = powerState
            effect1VC?.powerState = powerState
            effect2VC?.powerState = powerState
            effect3VC?.powerState = powerState
            effect4VC?.powerState = powerState
            pedal1VC?.powerState = powerState
            pedal2VC?.powerState = powerState
            pedal3VC?.powerState = powerState
            pedal4VC?.powerState = powerState
            cabinetVC?.powerState = powerState
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true

        bluetoothLogo.isHidden = true
        txLED.backgroundColour = NSColor.clear
        rxLED.backgroundColour = NSColor.clear
        
        if let appDelegate = NSApplication.shared().delegate as? AppDelegate {
            remoteManager = appDelegate.remoteManager
            remoteManager?.delegate = self
        }

        reset()
        
        configureAmplifiers()

        debugButton.isHidden = !ampManager.mocking
        preloadButton.isHidden = true
        
        let contrastColour = NSColor.white
        gainArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        volumeArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        trebleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        middleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        bassArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        presenceArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(contrastColour)
        effectsLoopArrow1.image = NSImage(named: "right-arrow")?.imageWithTintColor(NSColor.lead)
        effectsLoopArrow2.image = NSImage(named: "up-arrow")?.imageWithTintColor(NSColor.lead)
        gainLabel.textColor = contrastColour
        volumeLabel.textColor = contrastColour
        trebleLabel.textColor = contrastColour
        middleLabel.textColor = contrastColour
        bassLabel.textColor = contrastColour
        presenceLabel.textColor = contrastColour
        effectsLoopLabel.textColor = contrastColour
        pedalLeads.borderColor = NSColor.lead
        effectLeads.borderColor = NSColor.lead
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
        if let appView = view as? AppViewControl {
            if let image = NSImage(named: "background-texture") {
                appView.backgroundColour = NSColor(patternImage: image)
            }
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedDisplay":
                displayVC = segue.destinationController as? DisplayVC
            case "embedWeb":
                webVC = segue.destinationController as? WebVC
                webVC?.ampManager = ampManager
                webVC?.delegate = self
            case "embedCabinet":
                cabinetVC = segue.destinationController as? CabinetVC
            case "embedEffect1":
                effect1VC = segue.destinationController as? EffectVC
            case "embedEffect2":
                effect2VC = segue.destinationController as? EffectVC
            case "embedEffect3":
                effect3VC = segue.destinationController as? EffectVC
            case "embedEffect4":
                effect4VC = segue.destinationController as? EffectVC
            case "embedPedal1":
                pedal1VC = segue.destinationController as? PedalVC
            case "embedPedal2":
                pedal2VC = segue.destinationController as? PedalVC
            case "embedPedal3":
                pedal3VC = segue.destinationController as? PedalVC
            case "embedPedal4":
                pedal4VC = segue.destinationController as? PedalVC
            default: break
            }
        }
    }
    
    // MARK: Public functions
    func willImportPresetFromXml(_ xml: XMLDocument) {
        if let preset = ampManager.importPreset(xml) {
            var newPreset = preset
            newPreset.number = currentPreset?.number
            setPreset(newPreset)
            saveButton.setState(.warning)
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
            Flogger.log.verbose(" Powering off")
            cabinetVC?.state = .off
            powerState = .off
            setPreset(nil)
            sendNoAmplifier()
            preloadButton.isHidden = true
        } else {
            Flogger.log.verbose(" Powering on")
            sender.state = NSOffState
            powerState = .on
            cabinetVC?.state = .on
            sendCurrentAmplifier()
            ampManager.getPresets() {
                self.powerState = .on
                self.valueDidChangeForWheel(self.wheel, value: 0)
                self.preloadButton.isHidden = self.ampManager.mocking
                sender.state = NSOnState
            }
        }
    }
    
    @IBAction func willSave(_ sender: ActionButtonControl) {
        if sender.powerState == .on {
            if let currentPreset = currentPreset {
                if sender.currentState == .warning {
                    Flogger.log.verbose(" Saving effect")
                    exitButton.setState(.active)
                    ampManager.setPreset(currentPreset) { (preset) in
                        self.saveButton.setState(.ok)
                        self.displayVC?.setState(.edit)
                    }
                }
                else if sender.currentState == .ok {
                    Flogger.log.verbose(" Confirming effect")
                    ampManager.savePreset(currentPreset) { (saved) in
                        self.ampManager.resetPreset(self.wheel.intValue) { (preset) in
                            self.displayPreset(preset)
                            self.saveButton.setState(.active)
                            self.displayVC?.setState(.view)
                        }
                    }
                }
            }
        }
    }

    @IBAction func willBackup(_ sender: NSMenuItem) {
        Flogger.log.verbose(" Backing up presets")
        ampManager.saveBackup()
    }
    
    @IBAction func willRestore(_ sender: NSMenuItem) {
        if let backups = ampManager.backups() {
            if let latest = backups.keys.sorted().last {
                Flogger.log.verbose("Restoring from backup \"\(backups[latest]!)\" (\(latest))")
                ampManager.restoreFromBackup(date: latest)
            }
        }
    }
    
    @IBAction func willExit(_ sender: ActionButtonControl) {
        if sender.powerState == .on {
            Flogger.log.verbose(" Cancelling save")
            saveButton.setState(.active)
            exitButton.setState(.ok)
            ampManager.resetPreset(wheel.intValue) { (preset) in
                self.displayPreset(preset)
                self.exitButton.setState(.active)
                self.displayVC?.setState(.view)
            }
        }
    }
    
    @IBAction func willDebug(_ sender: NSButton) {
        debuggingConstraints = !debuggingConstraints
        if debuggingConstraints {
            var debugConstraints = [NSLayoutConstraint]()
            debugConstraints.append(contentsOf: view.constraints)
            debugConstraints.append(contentsOf: effectsSettings.constraints)
            debugConstraints.append(contentsOf: effectsArea.constraints)
            debugConstraints.append(contentsOf: pedalsArea.constraints)
            view.window?.visualizeConstraints(debugConstraints)
        } else {
            view.window?.visualizeConstraints([NSLayoutConstraint]())
        }
    }
    
    @IBAction func willPreloadAllPresets(_ sender: NSButton) {
        preloadButton.isEnabled = false
        ampManager.loadAllPresets() { (allLoaded) in
            self.preloadButton.isHidden = allLoaded
            self.preloadButton.isEnabled = !allLoaded
        }
    }

    // MARK: Private Functions
    fileprivate func reset() {
        statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
        statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
        bluetoothLabel.stringValue = ""
        presetsLabel.stringValue = ""
        statusLabel.textColor = .white
        bluetoothLabel.textColor = .white
        presetsLabel.textColor = .white
        powerButton.state = NSOffState
        cabinetVC?.state = ampManager.hasAnAmplifier ? .off : .disabled
        powerState = .off
    }
    
    fileprivate func setPreset(_ preset: BOPreset?) {
        currentPreset = preset
        displayPreset(preset)
        sendCurrentPreset()
    }
    
    fileprivate func configureAmplifiers() {
        ampManager = AmpManager()
        ampManager.delegate = self
        configureAmplifier()
    }
    
    fileprivate func configureAmplifier() {
        powerState = .off
    }
    
    fileprivate func displayPreset(_ value: Int) {
        ampManager.getCachedPreset(value) { (preset) in
            self.displayPreset(preset)
        }
    }
    
    fileprivate func displayPreset(_ preset: BOPreset?) {
        
        cabinetVC?.configureWithPreset(nil)
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

        cabinetVC?.configureWithPreset(preset)
        displayVC?.configureWithPreset(preset)
        for effect in preset?.effects ?? [BOEffect]() {
            displayEffect(effect)
        }
    }

    private func displayEffect(_ effect: BOEffect?) {
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
    
    fileprivate func presetDidChange() {
        saveButton.setState(.warning)
        exitButton.setState(.warning)
    }
    
    func sendCurrentAmplifier() {
        var message: DXMessage!
        if let amp = ampManager.currentAmplifier {
            if powerState == .on {
                message = DXMessage(command: .amplifier, data: DXAmplifier(dto: amp))
                sendMessage(message)
                return
            }
        }
        message = DXMessage(command: .amplifier, data: DXAmplifier(name: nil, manufacturer: nil))
        sendMessage(message)
    }
    
    func sendNoAmplifier() {
        var message: DXMessage!
        message = DXMessage(command: .amplifier, data: DXAmplifier(name: nil, manufacturer: nil))
        sendMessage(message)
    }
    
    func sendCurrentPreset() {
        var message: DXMessage!
        if let preset = currentPreset {
            message = DXMessage(command: .preset, data: DXPreset(dto: preset))
        } else {
            message = DXMessage(command: .preset, data: DXPreset(name: ""))
        }
        sendMessage(message)
    }
    
    func sendPresets() {
        var message: DXMessage!
        message = DXMessage(command: .presets, data: DXPresetList(names: ampManager.presetNames))
        sendMessage(message)
    }
    
    func sendMessage(_ message: DXMessage) {
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = NSColor.red
        } else {
            Flogger.log.error("Failed to send message. Command = \(message.command)")
        }
    }
    
    // MARK: Debug logging
    internal func logPreset(_ preset: BOPreset?) {
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
            text += "   Model: \(preset?.moduleName ?? "-unknown-") (\(preset?.module ?? -1))\n"
            text += "   Cabinet: \(preset?.cabinetName ?? "-unknown-") (\(preset?.cabinet ?? -1))\n"
            for effect in preset?.effects ?? [BOEffect]() {
                text += "   \(effect.type.rawValue): \(effect.name ?? "-empty-") - \(effect.enabled ? "ON" : "OFF") (colour \(effect.colour))\n"
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
        presetDidChange()
        sendCurrentPreset()
    }
}

extension MainVC: PedalVCDelegate {
    
    func settingsDidChangeForPedal(_ sender: PedalVC) {
        if let effect = sender.effect {
            for i in 0..<(currentPreset?.effects.count ?? 0) {
                if currentPreset!.effects[i].slot == effect.slot {
                    currentPreset!.effects[i] = effect
                }
            }
        }
        presetDidChange()
        sendCurrentPreset()
    }
}

extension MainVC: EffectVCDelegate {
    
    func settingsDidChangeForEffect(_ sender: EffectVC) {
        if let effect = sender.effect {
            for i in 0..<(currentPreset?.effects.count ?? 0) {
                if currentPreset!.effects[i].slot == effect.slot {
                    currentPreset!.effects[i] = effect
                }
            }
        }
        presetDidChange()
        sendCurrentPreset()
    }
}

extension MainVC: WheelDelegate {
    // MARK: Wheel delegate
    
    func valueIsChangingForWheel(_ sender: WheelControl, value: Int) {
        switch saveButton.currentState {
        case .active:
            switch sender {
            case wheel:
                Flogger.log.debug("Wheel value is changing to \(value)")
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
                Flogger.log.debug("Wheel value changed to \(value)")
                saveButton.setState(.active)
                exitButton.setState(.active)
                ampManager.getPreset(value,
                                     fromAmplifier: true) { (preset) in
                    self.setPreset(preset)
                    self.logPreset(self.currentPreset)
                }
            default:
                Flogger.log.error("Don't know what wheel sent this event")
            }
        case .warning:
            logPreset(currentPreset)
            break
        case .ok:
            break
        }
    }
}

extension MainVC: AmpManagerDelegate {
    
    func deviceConnected(ampManager: AmpManager) {
        Flogger.log.verbose(" Connected")
        sendCurrentAmplifier()
        statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
        statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
    }
    
    func deviceOpened(ampManager: AmpManager) {
        Flogger.log.verbose(" Opened")
        configureAmplifiers()
        sendCurrentPreset()
    }
    
    func presetCountChanged(ampManager: AmpManager, to: UInt) {
        presetsLabel.stringValue = "Loaded \(to) preset\(to == 1 ? "" : "s")"
        preloadButton.isHidden = (to == 100) || ampManager.mocking
    }
    
    func deviceClosed(ampManager: AmpManager) {
        Flogger.log.verbose(" Closed")
        setPreset(nil)
    }
    
    func deviceDisconnected(ampManager: AmpManager) {
        Flogger.log.verbose(" Disconnected")
        reset()
        setPreset(nil)
        sendCurrentAmplifier()
        statusLED.backgroundColour = ampManager.hasAnAmplifier ? .green : .red
        statusLabel.stringValue = "\(ampManager.currentAmplifierName) connected"
    }
    
    func gainChanged(ampManager: AmpManager, by: Float) {
        gainKnob.setFloatValueTo(max(min(gainKnob.floatValue + by, 10.0), 0.0))
    }
    
    func volumeChanged(ampManager: AmpManager, by: Float) {
        volumeKnob.setFloatValueTo(max(min(volumeKnob.floatValue + by, 10.0), 0.0))
    }
    
    func trebleChanged(ampManager: AmpManager, by: Float) {
        trebleKnob.setFloatValueTo(max(min(trebleKnob.floatValue + by, 10.0), 0.0))
    }
    
    func middleChanged(ampManager: AmpManager, by: Float) {
        middleKnob.setFloatValueTo(max(min(middleKnob.floatValue + by, 10.0), 0.0))
    }
    
    func bassChanged(ampManager: AmpManager, by: Float) {
        bassKnob.setFloatValueTo(max(min(bassKnob.floatValue + by, 10.0), 0.0))
    }
    
    func presenceChanged(ampManager: AmpManager, by: Float) {
        presenceKnob.setFloatValueTo(max(min(presenceKnob.floatValue + by, 10.0), 0.0))
    }
}

extension MainVC: WebVCDelegate {
    
    func didSelectPreset(preset: BOPreset?) {
        var newPreset = preset
        if let _ = newPreset {
            newPreset!.number = currentPreset?.number
        }
        setPreset(newPreset)
        saveButton.setState(.warning)
    }
}

extension MainVC: RemoteManagerDelegate {
    func remoteManagerDidStart(_ manager: RemoteManager) {
        bluetoothLogo.isHidden = false
        bluetoothLogo.alphaValue = 0.5
    }
    
    func remoteManagerDidConnect(_ manager: RemoteManager) {
        bluetoothLogo.alphaValue = 1.0
    }
    
    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        txLED.backgroundColour = NSColor.clear
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        rxLED.backgroundColour = NSColor.green
        do {
            let message = try DXMessage(data: data)
            Flogger.log.verbose("Message: \(message.command.rawValue)")
            switch message.command as RequestType {
            case .amplifier:
                sendCurrentAmplifier()
            case .presets:
                sendPresets()
            case .preset:
                if message.content == nil {
                    sendCurrentPreset()
                } else {
                    let preset = try DXPreset(data: message.content)
                    if let number = preset.number {
                        ampManager.getPreset(Int(number),
                                                  fromAmplifier: true) { (preset) in
                            self.setPreset(preset)
                            self.logPreset(preset)
                        }
                    }
                }
            case .changePreset:
                let preset = try DXPreset(data: message.content)
                preset.copyInto(preset: &currentPreset)
                displayPreset(currentPreset)
                presetDidChange()
            }
        } catch {
            Flogger.log.error("Receive Failure: Couldn't decode DXMessage or DXPreset")
        }
        rxLED.backgroundColour = NSColor.clear
    }
    
    func remoteManagerDidDisconnect(_ manager: RemoteManager) {
        bluetoothLogo.alphaValue = 0.5
    }

    func remoteManagerDidStop(_ manager: RemoteManager) {
        bluetoothLogo.isHidden = true
    }

}
