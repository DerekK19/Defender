//
//  DisplayVC.swift
//  Defender
//
//  Created by Derek Knight on 11/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class DisplayVC: NSViewController {

    @IBOutlet weak var display: DisplayControl!
    @IBOutlet weak var presetNumber: NSTextField!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var amplifierName: NSTextField!
    @IBOutlet weak var stompValue: NSTextField!
    @IBOutlet weak var modulationValue: NSTextField!
    @IBOutlet weak var delayValue: NSTextField!
    @IBOutlet weak var reverbValue: NSTextField!

    var displayBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
    var displayForegroundColour = NSColor(red: 0.3, green: 0.38, blue: 0.6, alpha: 1.0)
    
    var powerState: PowerState = .off {
        didSet {
            var newBackgroundColour = NSColor()
            if powerState == .off {
                newBackgroundColour = NSColor(red: 0.31, green: 0.39, blue: 0.44, alpha: 1.0)
            } else {
                newBackgroundColour = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
            }
            self.displayBackgroundColour = newBackgroundColour
            self.display.backgroundColour = newBackgroundColour
            self.presetNumber.backgroundColor = displayBackgroundColour
            self.presetNumber.textColor = displayForegroundColour
            self.presetName.backgroundColor = displayForegroundColour
            self.presetName.textColor = displayBackgroundColour
            self.amplifierName.backgroundColor = displayForegroundColour
            self.amplifierName.textColor = displayBackgroundColour
            self.configureWithPreset(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Initialization code here
    }
    
    override func viewDidLoad() {
        self.powerState = .off
        stompValue.isEnabled = false
        modulationValue.isEnabled = false
        delayValue.isEnabled = false
        reverbValue.isEnabled = false
    }
    
    func configureWithPreset(_ preset: DTOPreset?) {
        let presetKnown = preset != nil
        presetNumber.stringValue = presetKnown ? String(format: "%02d", preset?.number ?? 0) : ""
        presetName.stringValue = preset?.name ?? ""
        amplifierName.stringValue = preset?.modelName ?? ""
        setValueForFxField(stompValue, text: preset?.stompEffect?.name, presetKnown: presetKnown)
        setValueForFxField(modulationValue, text: preset?.modulationEffect?.name, presetKnown: presetKnown)
        setValueForFxField(delayValue, text: preset?.delayEffect?.name, presetKnown: presetKnown)
        setValueForFxField(reverbValue, text: preset?.reverbEffect?.name, presetKnown: presetKnown)
    }
    
    fileprivate func setValueForFxField(_ textField: NSTextField, text: String?, presetKnown: Bool) {
        switch powerState {
        case .off:
            textField.isHidden = true
            textField.backgroundColor = displayBackgroundColour
            textField.textColor = displayBackgroundColour
            textField.stringValue = ""
        case .on:
            textField.isHidden = false
            textField.backgroundColor = text != nil ? displayForegroundColour : displayBackgroundColour
            textField.textColor = text != nil ? displayBackgroundColour : displayForegroundColour
            textField.stringValue = text ?? (presetKnown ? "- EMPTY -" : "")
        }
    }
    
}
