//
//  InterfaceController.swift
//  Watchkit Extension
//
//  Created by Derek Knight on 11/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var amplifierLabel: WKInterfaceLabel!
    @IBOutlet weak var bluetoothImage: WKInterfaceImage!
    
    private var phoneController: PhoneSessionController?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if phoneController == nil {
            phoneController = PhoneSessionController()
            phoneController?.delegate = self
        } else {
            if let chosenPreset = DataManager.instance.chosenPreset {
                phoneController?.sendMessage(.preset, content: chosenPreset)
                DataManager.instance.chosenPreset = nil
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

extension InterfaceController: PhoneSessionControllerDelegate {
    
    func controllerDidConnect(_ controller: PhoneSessionController) {
        bluetoothImage.setHidden(false)
    }

    func controllerDidDisconnect(_ controller: PhoneSessionController) {
        bluetoothImage.setHidden(true)
    }
    
    func controller(_ controller: PhoneSessionController, currentAmplifier: String) {
        amplifierLabel.setText(currentAmplifier)
    }
    
    func controller(_ controller: PhoneSessionController, presets: [String]) {
        DataManager.instance.presets = presets
    }
    
    func controller(_ controller: PhoneSessionController, currentPreset: String) {
        DataManager.instance.currentPreset = currentPreset
    }
}
