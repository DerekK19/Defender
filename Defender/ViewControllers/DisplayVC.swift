//
//  DisplayVC.swift
//  Defender
//
//  Created by Derek Knight on 11/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

enum PowerState {
    case On
    case Off
}

class DisplayVC: NSViewController {

    @IBOutlet weak var display: DisplayControl!
    @IBOutlet weak var presetNumber: NSTextField!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var amplifierName: NSTextField!
    @IBOutlet weak var stompValue: NSTextField!
    @IBOutlet weak var modValue: NSTextField!
    @IBOutlet weak var delayValue: NSTextField!
    @IBOutlet weak var reverbValue: NSTextField!

    var displayBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
    var displayForegroundColour = NSColor(red: 0.3, green: 0.38, blue: 0.6, alpha: 1.0)
    
    var powerState: PowerState = .Off {
        didSet {
            var newBackgroundColour = NSColor()
            if powerState == .Off {
                NSLog("Display powering off")
                newBackgroundColour = NSColor(red: 0.31, green: 0.39, blue: 0.44, alpha: 1.0)
            } else {
                NSLog("Display powering on")
                newBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
            }
            self.displayBackgroundColour = newBackgroundColour
            self.display.backgroundColour = newBackgroundColour
            self.configureWithPreset(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Initialization code here
        
    }
    
    override func viewDidLoad() {
        self.powerState = .Off
        presetNumber.backgroundColor = displayBackgroundColour
        presetNumber.textColor = displayForegroundColour
        presetName.backgroundColor = displayForegroundColour
        presetName.textColor = displayBackgroundColour
        amplifierName.backgroundColor = displayForegroundColour
        amplifierName.textColor = displayBackgroundColour
        stompValue.enabled = false
        modValue.enabled = false
        delayValue.enabled = false
        reverbValue.enabled = false
    }
    
    func configureWithPreset(preset: DTOPreset?) {
        let presetKnown = preset != nil
        presetNumber.stringValue = presetKnown ? String(format: "%02d", preset?.number ?? 0) : ""
        presetName.stringValue = preset?.name ?? ""
        amplifierName.stringValue = preset?.modelName ?? ""
        setValueForFxField(stompValue, text: preset?.stompName, presetKnown: presetKnown)
        setValueForFxField(modValue, text: preset?.modName, presetKnown: presetKnown)
        setValueForFxField(delayValue, text: preset?.delayName, presetKnown: presetKnown)
        setValueForFxField(reverbValue, text: preset?.reverbName, presetKnown: presetKnown)
    }
    
    private func setValueForFxField(textField: NSTextField, text: String?, presetKnown: Bool) {
        switch powerState {
        case .Off:
            NSLog("Set off state for field")
            textField.hidden = true
            textField.backgroundColor = displayBackgroundColour
            textField.textColor = displayBackgroundColour
            textField.stringValue = ""
        case .On:
            NSLog("Set on state for field")
            textField.hidden = false
            textField.backgroundColor = text != nil ? displayForegroundColour : displayBackgroundColour
            textField.textColor = text != nil ? displayBackgroundColour : displayForegroundColour
            textField.stringValue = text ?? (presetKnown ? "- EMPTY -" : "")
        }
    }
    
}
