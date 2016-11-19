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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txLED.backgroundColour = UIColor.clear
        rxLED.backgroundColour = UIColor.clear

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
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = UIColor.red
            bluetoothLabel.text = "Sending"
        } else {
            bluetoothLabel.text = "Unsent"
        }
    }

    func sendGetPreset(_ number: UInt8) {
        var message: DXMessage!
        let preset = DXPreset(name: "")
        preset.number = number
        message = DXMessage(command: .preset, data: preset)
        if remoteManager?.send(message) == true {
            txLED.backgroundColour = UIColor.red
            bluetoothLabel.text = "Sending"
        } else {
            bluetoothLabel.text = "Unsent"
        }
    }

}

extension MainVC: RemoteManagerDelegate {
    func remoteManagerAvailable(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLabel.text = "Started"
        }
    }
    
    func remoteManagerConnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLabel.text = "Connected"
            self.amplifierLabel.isHidden = false
            self.amplifierLabel.text = ""
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                self.sendGetAmplifier()
            }
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        DispatchQueue.main.async {
            self.txLED.backgroundColour = UIColor.clear
            self.bluetoothLabel.text = "Sent"
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        DispatchQueue.main.async {
            self.rxLED.backgroundColour = UIColor.green
            do {
                let message = try DXMessage(data: data)
                switch message.command as RequestType {
                case .amplifier:
                    let amp = try DXAmplifier(data: message.content)
                    self.bluetoothLabel.text = "Received"
                    self.amplifierLabel.text = amp.name
                    self.presetLabel.isHidden = false
                    self.presetLabel.text = ""
                case .preset:
                    let preset = try DXPreset(data: message.content)
                    self.bluetoothLabel.text = "Received"
                    self.presetLabel.text = preset.name
                    self.prevPreset.isHidden = false
                    self.nextPreset.isHidden = false
                    self.presetNumber = preset.number
                }
            } catch {
                self.bluetoothLabel.text = "Received Badness"
            }
            self.rxLED.backgroundColour = UIColor.clear
        }
    }
    
    func remoteManagerDisconnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.amplifierLabel.isHidden = true
            self.presetLabel.isHidden = true
            self.prevPreset.isHidden = true
            self.nextPreset.isHidden = true
            self.bluetoothLabel.text = "Disconnected"
        }
    }
        
    func remoteManagerUnavailable(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.amplifierLabel.isHidden = true
            self.presetLabel.isHidden = true
            self.prevPreset.isHidden = true
            self.nextPreset.isHidden = true
            self.bluetoothLabel.text = "Unavailable"
        }
    }
}

