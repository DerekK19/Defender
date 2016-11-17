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
    @IBOutlet weak var bluetoothLabel: UILabel!

    fileprivate var remoteManager: RemoteManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                if self.remoteManager?.send("Hello peripheral") == true {
                    self.bluetoothLabel.text = "Sending"
                } else {
                    self.bluetoothLabel.text = "Unsent"
                }
            }
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didSend success: Bool) {
        DispatchQueue.main.async {
            self.bluetoothLabel.text = "Sent"
        }
    }
    
    func remoteManager(_ manager: RemoteManager, didReceive data: Data) {
        DispatchQueue.main.async {
            let amp = DXAmplifier(data: data)
            self.bluetoothLabel.text = "Received \(amp.name ?? "")"
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

