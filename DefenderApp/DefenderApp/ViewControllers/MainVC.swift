//
//  ViewController.swift
//  DefenderApp
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger
import RemoteDefender

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
                self.presetVC = segue.destination as? PresetVC
                self.presetVC?.presetDelegate = self
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
            Flogger.log.error("Failed to send message. Command = \(message.command)")
        }

    }
    
    // MARK: Debug logging
    internal func logPreset(_ preset: DXPreset?) {
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
            for effect in preset?.effects ?? [DXEffect]() {
                text += "   \(effect.type.rawValue): \(effect.name ?? "-empty-") - \(effect.enabled! ? "ON" : "OFF")\n"
                text += "    Knobs: \(effect.knobs.count) - "
                effect.knobs.forEach { text += "\(String(format: "%0.2f", $0.value)) " }
                text += "slot \(effect.slot!)\n"
            }
            Flogger.log.info(text)
        }
    }
}

extension MainVC: PresetVCDelegate {
    func settingsDidChangeForPreset(_ sender: PresetVC, preset: DXPreset?) {
        Flogger.log.info("Preset changed")
        if let preset = preset {
            sendChangePreset(preset: preset)
        }
    }
}

extension MainVC: RemoteManagerDelegate {
    func remoteManagerAvailable(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.isHidden = false
            self.bluetoothLogo.alpha = 0.5
        }
    }
    
    func remoteManagerConnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLogo.alpha = 1.0
            self.bluetoothLabel.isHidden = false
            self.amplifierLabel.isHidden = false
            self.amplifierLabel.text = ""
            self.presetLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                self.sendGetAmplifier()
            }
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        DispatchQueue.main.async {
            self.txLED.backgroundColour = UIColor.clear
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        DispatchQueue.main.async {
            self.rxLED.backgroundColour = UIColor.green
            do {
                let message = try DXMessage(data: data)
                Flogger.log.verbose("Message: \(message.command.rawValue)")
                switch message.command as RequestType {
                case .amplifier:
                    let amp = try DXAmplifier(data: message.content)
                    self.amplifierLabel.text = amp.name ?? "No Amplifier"
                    self.presetVC?.powerState = amp.name == nil ? .off : .on
                    self.sendGetPreset(nil)
                case .preset, .changePreset:
                    let preset = try DXPreset(data: message.content)
                    self.logPreset(preset)
                    self.presetLabel.text = preset.name
                    self.presetNumber = preset.number
                    self.presetVC?.preset = preset
                    self.prevPreset.isHidden = preset.number == nil
                    self.nextPreset.isHidden = preset.number == nil
                }
            } catch {
                Flogger.log.error("Receive Failure: Couldn't decode DXMessage, DXAmplifier or DXPreset")
            }
            self.rxLED.backgroundColour = UIColor.clear
        }
    }
    
    func remoteManagerDisconnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.presetVC?.powerState = .off
            self.bluetoothLogo.alpha = 0.5
            self.bluetoothLabel.isHidden = true
            self.amplifierLabel.isHidden = true
            self.amplifierLabel.text = ""
            self.presetLabel.isHidden = true
            self.presetLabel.text = ""
            self.prevPreset.isHidden = true
            self.nextPreset.isHidden = true
        }
    }
        
    func remoteManagerUnavailable(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.presetVC?.powerState = .off
            self.bluetoothLogo.isHidden = true
            self.bluetoothLabel.isHidden = true
            self.amplifierLabel.isHidden = true
            self.amplifierLabel.text = ""
            self.presetLabel.isHidden = true
            self.presetLabel.text = ""
            self.prevPreset.isHidden = true
            self.nextPreset.isHidden = true
        }
    }
}

