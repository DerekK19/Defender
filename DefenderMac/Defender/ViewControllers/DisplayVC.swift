//
//  DisplayVC.swift
//  Defender
//
//  Created by Derek Knight on 11/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum DisplayState {
    case view
    case edit
}

class DisplayVC: NSViewController {

    @IBOutlet weak var display: DisplayControl!
    @IBOutlet weak var presetNumber: NSTextField!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var amplifierName: NSTextField!
    @IBOutlet weak var stompValue: NSTextField!
    @IBOutlet weak var modulationValue: NSTextField!
    @IBOutlet weak var delayValue: NSTextField!
    @IBOutlet weak var reverbValue: NSTextField!
    @IBOutlet weak var shade: ShadeControl!

    var displayBackgroundColour = NSColor.LCDLightBlue
    var displayForegroundColour = NSColor.LCDDarkBlue
    
    var currentState: DisplayState = .view

    var powerState: PowerState = .off {
        didSet {
            shade.isOpen = powerState == .on
            display.backgroundColour = displayBackgroundColour
            presetNumber.backgroundColor = displayBackgroundColour
            presetNumber.textColor = displayForegroundColour
            amplifierName.backgroundColor = displayForegroundColour
            amplifierName.textColor = displayBackgroundColour
            setState(currentState)
            configureWithPreset(nil)
        }
    }
    
    func setState(_ state: DisplayState) {
        currentState = state
        switch currentState {
        case .view:
            presetName.backgroundColor = displayForegroundColour
            presetName.textColor = displayBackgroundColour
            presetName.isEnabled = false
            presetName.isEditable = false
            presetName.resignFirstResponder()
        case .edit:
            presetName.backgroundColor = NSColor.white
            presetName.textColor = NSColor.black
            presetName.isEnabled = true
            presetName.isEditable = true
            if presetName.acceptsFirstResponder {
                presetName.window?.makeFirstResponder(presetName)
            }
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
        powerState = .off
        stompValue.isEnabled = false
        modulationValue.isEnabled = false
        delayValue.isEnabled = false
        reverbValue.isEnabled = false
    }
    
    func configureWithPreset(_ preset: DTOPreset?) {
        let presetKnown = preset != nil
        if let number = preset?.number {
            presetNumber.stringValue = presetKnown ? String(format: "%02d", number) : ""
        } else {
            presetNumber.stringValue = ""
        }
        presetName.stringValue = preset?.name ?? ""
        amplifierName.stringValue = preset?.moduleName ?? ""
        setValueForFxField(stompValue, effect: preset?.effects.filter( { $0.type == .Stomp } ).first, presetKnown: presetKnown)
        setValueForFxField(modulationValue, effect: preset?.effects.filter( { $0.type == .Modulation } ).first, presetKnown: presetKnown)
        setValueForFxField(delayValue, effect: preset?.effects.filter( { $0.type == .Delay } ).first, presetKnown: presetKnown)
        setValueForFxField(reverbValue, effect: preset?.effects.filter( { $0.type == .Reverb } ).first, presetKnown: presetKnown)
    }
    
    fileprivate func setValueForFxField(_ textField: NSTextField, effect: DTOEffect?, presetKnown: Bool) {
        switch powerState {
        case .off:
            textField.isHidden = true
            textField.backgroundColor = displayBackgroundColour
            textField.textColor = displayBackgroundColour
            textField.stringValue = ""
        case .on:
            switch effect?.enabled ?? false {
            case true:
                textField.isHidden = false
                textField.backgroundColor = effect?.name != nil ? displayForegroundColour : displayBackgroundColour
                textField.textColor = effect?.name != nil ? displayBackgroundColour : displayForegroundColour
                textField.stringValue = effect?.name ?? (presetKnown ? "- EMPTY -" : "")
            case false:
                textField.isHidden = false
                textField.backgroundColor = displayBackgroundColour
                textField.textColor = displayForegroundColour
                textField.stringValue = effect?.name ?? (presetKnown ? "- EMPTY -" : "")
            }
        }
    }
    
}
