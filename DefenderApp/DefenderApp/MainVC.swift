//
//  ViewController.swift
//  DefenderApp
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
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

    func sendMessage(_ message: DXMessage) {
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = UIColor.red
        } else {
            NSLog("Failed to send message. Command = \(message.command)")
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
                self.DebugPrint("Message: \(message.command.rawValue)")
                switch message.command as RequestType {
                case .amplifier:
                    let amp = try DXAmplifier(data: message.content)
                    self.amplifierLabel.text = amp.name
                    self.sendGetPreset(nil)
                case .preset:
                    let preset = try DXPreset(data: message.content)
                    self.presetLabel.text = preset.name
                    self.presetNumber = preset.number
                    self.prevPreset.isHidden = preset.number == nil
                    self.nextPreset.isHidden = preset.number == nil
                }
            } catch {
                NSLog("Receive Failure: Couldn't decode DXMessage, DXAmplifier or DXPreset")
            }
            self.rxLED.backgroundColour = UIColor.clear
        }
    }
    
    func remoteManagerDisconnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
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

