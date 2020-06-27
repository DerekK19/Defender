//
//  ViewController.swift
//  DefenderApp
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var bluetoothLogo: UIImageView!
    @IBOutlet weak var txLED: LEDControl!
    @IBOutlet weak var rxLED: LEDControl!
    @IBOutlet weak var bluetoothLabel: UILabel!
    @IBOutlet weak var amplifierLabel: UILabel!
    @IBOutlet weak var presetLabel: UILabel!
    @IBOutlet weak var prevPreset: UIButton!
    @IBOutlet weak var nextPreset: UIButton!
    @IBOutlet weak var presetVC: PresetVC?

    fileprivate var remoteManager: RemoteManager?
    fileprivate var watchManager: WatchManager?
    
    var presetNumber: UInt8?
    
    let verbose = true

    override func viewDidLoad() {
        super.viewDidLoad()

        bluetoothLogo.isHidden = true
        bluetoothLabel.isHidden = true
        txLED.backgroundColour = UIColor.clear
        rxLED.backgroundColour = UIColor.clear

        bluetoothLabel.text = ""
        amplifierLabel.text = ""
        presetLabel.text = ""
        
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            remoteManager = appDelegate.remoteManager
            remoteManager?.delegate = self
            watchManager = appDelegate.watchManager
            watchManager?.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        remoteManager?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        remoteManager?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedPreset":
                presetVC = segue.destination as? PresetVC
                presetVC?.presetDelegate = self
            default: break
            }
        }
    }
    
    // MARK: Action functions
    
    @IBAction func didTapBluetoothLogo(_ sender: AnyObject) {
        if bluetoothLogo.alpha != 1.0 {
            remoteManager?.rescan()
        }
    }
    
    @IBAction func willGetPrevPreset(_ sender: UIButton) {
        if let number = presetNumber {
            var nextNumber = number
            if number > 0 {
                nextNumber = number - 1
            } else {
                nextNumber = 99
            }
            sendGetPreset(nextNumber)
        }
    }
    
    @IBAction func willGetNextPreset(_ sender: UIButton) {
        if let number = presetNumber {
            var nextNumber = number
            if number < 99 {
                nextNumber = number + 1
            } else {
                nextNumber = 0
            }
            sendGetPreset(nextNumber)
        }
    }
    
    // MARK: Private functions
    
    func sendGetAmplifier() {
        let message = DXMessage(command: .amplifier, data: nil)
        sendMessage(message)
    }
    
    func sendGetPresets() {
        let message = DXMessage(command: .presets, data: nil)
        sendMessage(message)
    }
    
    func sendGetPreset(_ number: UInt8?) {
        var message: DXMessage!
        let preset = DXPreset(name: "")
        if let number = number {
            preset.number = number
            message = DXMessage(command: .preset, data: preset)
        } else {
            message = DXMessage(command: .preset, data: nil)
        }
        sendMessage(message)
    }

    func sendChangePreset(preset: DXPreset) {
        let message = DXMessage(command: .changePreset, data: preset)
        sendMessage(message)
    }
    
    func sendMessage(_ message: DXMessage) {
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = UIColor.red
        } else {
            ULog.error("Failed to send message. Command = %@", String(describing: message.command))
        }

    }
    
    // MARK: Debug logging
    internal func logPreset(_ preset: DXPreset?) {
        if verbose {
            var text = "\n"
            if let number = preset?.number {
                text += String(format:"  Preset %d", number)
            } else {
                text += "  Preset -unknown-"
            }
            text += " - \(preset?.name ?? "-unknown-")\n"
            if let gain = preset?.gain1 {
                text += String(format: "   Gain: %0.2f\n", gain)
            } else {
                text += "   Gain: -unset-\n"
            }
            if let volume = preset?.volume {
                text += String(format: "   Volume: %0.2f\n", volume)
            } else {
                text += "   Volume: -unset-\n"
            }
            if let treble = preset?.treble {
                text += String(format: "   Treble: %0.2f\n", treble)
            } else {
                text += "   Treble: -unset-\n"
            }
            if let middle = preset?.middle {
                text += String(format: "   Middle: %0.2f\n", middle)
            } else {
                text += "   Middle: -unset-\n"
            }
            if let bass = preset?.bass {
                text += String(format: "   Bass: %0.2f\n", bass)
            } else {
                text += "   Bass: -unset-\n"
            }
            if let presence = preset?.presence {
                text += String(format: "   Reverb/Presence: %0.2f\n", presence)
            } else {
                text += "   Reverb/Presence: -unset-\n"
            }
            text += String(format: "   Model: %@\n", preset?.moduleName ?? "-unknown-")
            text += String(format: "   Cabinet: %@)\n", preset?.cabinetName ?? "-unknown-")
            for effect in preset?.effects ?? [DXEffect]() {
                text += String(format: "   %@: %@ - %@\n", effect.type.rawValue, effect.name ?? "-empty-", effect.enabled! ? "ON" : "OFF")
                text += String(format: "    Knobs: %d - ", effect.knobs.count)
                effect.knobs.forEach { text += String(format: "%0.2f ", $0.value) }
                text += String(format: "slot %d)\n", effect.slot!)
            }
            ULog.info("%@", text)
        }
    }
}

extension MainVC: PresetVCDelegate {
    func settingsDidChangeForPreset(_ sender: PresetVC, preset: DXPreset?) {
        ULog.info("Preset changed")
        if let preset = preset {
            sendChangePreset(preset: preset)
        }
    }
}

extension MainVC: RemoteManagerDelegate {
    func remoteManagerAvailable(_ manager: RemoteManager) {
        bluetoothLogo.isHidden = false
        bluetoothLogo.alpha = 0.5
    }
    
    func remoteManagerConnected(_ manager: RemoteManager) {
        bluetoothLogo.alpha = 1.0
        bluetoothLabel.isHidden = false
        amplifierLabel.isHidden = false
        amplifierLabel.text = ""
        presetLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
            self.sendGetAmplifier()
        }
        watchManager?.connect()
    }
    
    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        txLED.backgroundColour = UIColor.clear
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        rxLED.backgroundColour = UIColor.green
        do {
            let message = try DXMessage(data: data)
            ULog.verbose("Message: %@", message.command.rawValue)
            switch message.command as RequestType {
            case .amplifier:
                let amp = try DXAmplifier(data: message.content)
                watchManager?.amplifier(amp.name ?? "No amplifier")
                amplifierLabel.text = amp.name ?? "No Amplifier"
                presetVC?.powerState = amp.name == nil ? .off : .on
                sendGetPresets()
            case .presets:
                let presets = try DXPresetList(data: message.content)
                ULog.verbose("Presets : %d", presets.names.count)
                watchManager?.presets(presets.names)
                sendGetPreset(nil)
            case .preset, .changePreset:
                let preset = try DXPreset(data: message.content)
                logPreset(preset)
                watchManager?.preset(preset.name)
                presetLabel.text = preset.name
                presetNumber = preset.number
                presetVC?.preset = preset
                prevPreset.isHidden = preset.number == nil
                nextPreset.isHidden = preset.number == nil
            }
        } catch {
            ULog.error("Receive Failure: Couldn't decode DXMessage, DXAmplifier or DXPreset")
        }
        rxLED.backgroundColour = UIColor.clear
    }

    func remoteManagerDisconnected(_ manager: RemoteManager) {
        presetVC?.powerState = .off
        bluetoothLogo.alpha = 0.5
        bluetoothLabel.isHidden = true
        amplifierLabel.isHidden = true
        amplifierLabel.text = ""
        presetLabel.isHidden = true
        presetLabel.text = ""
        prevPreset.isHidden = true
        nextPreset.isHidden = true
        watchManager?.disconnect()
    }
    
    func remoteManagerUnavailable(_ manager: RemoteManager) {
        presetVC?.powerState = .off
        bluetoothLogo.isHidden = true
        bluetoothLabel.isHidden = true
        amplifierLabel.isHidden = true
        amplifierLabel.text = ""
        presetLabel.isHidden = true
        presetLabel.text = ""
        prevPreset.isHidden = true
        nextPreset.isHidden = true
    }
}

extension MainVC: WatchManagerDelegate {
    func watchManager(_ manager: WatchManager, didChoosePreset index: UInt8) {
        ULog.verbose("Choose preset: %d", index)
        sendGetPreset(index)
    }
}
