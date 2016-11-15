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

        remoteManager = RemoteManager(delegate: self)
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

