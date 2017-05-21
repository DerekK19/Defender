//
//  PresetsController.swift
//  DefenderApp
//
//  Created by Derek Knight on 4/02/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import WatchKit
import Foundation


class PresetsController: WKInterfaceController {

    @IBOutlet var presetLabel: WKInterfaceLabel!
    @IBOutlet var presetList: WKInterfacePicker!
    
    private var pickerItems = [WKPickerItem]()
    private var currentChoice: UInt8 = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        setPresets(DataManager.instance.presets)
        setPreset(DataManager.instance.currentPreset)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setPreset(_ name: String) {
        presetLabel.setText(name)
    }
    
    func setPresets(_ names: [String]) {
        pickerItems = names.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0
            return pickerItem
        }
        presetList.setItems(pickerItems)
    }
    
    @IBAction func didSelectPreset(value: UInt8) {
        currentChoice = value
    }
    
    @IBAction func didChoosePreset() {
        DataManager.instance.chosenPreset = currentChoice
        WKInterfaceDevice.current().play(.success)
    }
}
