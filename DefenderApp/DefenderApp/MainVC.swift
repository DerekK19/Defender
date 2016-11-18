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

    fileprivate var remoteManager: RemoteManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txLED.backgroundColour = UIColor.clear
        rxLED.backgroundColour = UIColor.clear

        amplifierLabel.text = ""
        
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                let request = DXMessage(command: .amplifier, data: nil)
                if self.remoteManager?.send(request) == true {
                    self.txLED.backgroundColour = UIColor.red
                    self.bluetoothLabel.text = "Sending"
                } else {
                    self.bluetoothLabel.text = "Unsent"
                }
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
                }
            } catch {
                self.bluetoothLabel.text = "Received Badness"
            }
            self.rxLED.backgroundColour = UIColor.clear
        }
    }
    
    func remoteManagerDisconnected(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLabel.text = "Disconnected"
        }
    }
        
    func remoteManagerUnavailable(_ manager: RemoteManager) {
        DispatchQueue.main.async {
            self.bluetoothLabel.text = "Connected"
        }
    }
}

