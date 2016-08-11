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

    @IBOutlet weak var presetNumber: NSTextField!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var amplifierName: NSTextField!
    @IBOutlet weak var stompValue: NSTextField!
    @IBOutlet weak var modValue: NSTextField!
    @IBOutlet weak var delayValue: NSTextField!
    @IBOutlet weak var reverbValue: NSTextField!

    let displayForegroundColour = NSColor(red: 0.3, green: 0.38, blue: 0.6, alpha: 1.0)
    let displayBackgroundColour = NSColor(colorLiteralRed: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Initialization code here
        
    }
    
    override func viewDidLoad() {
        presetNumber.textColor = displayForegroundColour
        presetName.backgroundColor = displayForegroundColour
        presetName.textColor = displayBackgroundColour
        amplifierName.backgroundColor = displayForegroundColour
        amplifierName.textColor = displayBackgroundColour
        stompValue.backgroundColor = displayForegroundColour
        stompValue.textColor = displayBackgroundColour
        modValue.backgroundColor = displayForegroundColour
        modValue.textColor = displayBackgroundColour
        delayValue.backgroundColor = displayForegroundColour
        delayValue.textColor = displayBackgroundColour
        reverbValue.backgroundColor = displayForegroundColour
        reverbValue.textColor = displayBackgroundColour
    }
    
    func configureWithPreset(preset: DTOPreset?) {
        presetNumber.stringValue = preset != nil ? String(format: "%02d", preset!.number) : ""
        presetName.stringValue = preset?.name ?? ""
        amplifierName.stringValue = preset?.modelName ?? ""
        stompValue.backgroundColor = preset?.stompName != nil ? displayForegroundColour : displayBackgroundColour
        stompValue.textColor = preset?.stompName != nil ? displayBackgroundColour : displayForegroundColour
        stompValue.stringValue = preset?.stompName ?? (preset != nil ? "- EMPTY -" : "")
        modValue.backgroundColor = preset?.modName != nil ? displayForegroundColour : displayBackgroundColour
        modValue.textColor = preset?.modName != nil ? displayBackgroundColour : displayForegroundColour
        modValue.stringValue = preset?.modName ?? (preset != nil ? "- EMPTY -" : "")
        delayValue.backgroundColor = preset?.delayName != nil ? displayForegroundColour : displayBackgroundColour
        delayValue.textColor = preset?.delayName != nil ? displayBackgroundColour : displayForegroundColour
        delayValue.stringValue = preset?.delayName ?? (preset != nil ? "- EMPTY -" : "")
        reverbValue.backgroundColor = preset?.reverbName != nil ? displayForegroundColour : displayBackgroundColour
        reverbValue.textColor = preset?.reverbName != nil ? displayBackgroundColour : displayForegroundColour
        reverbValue.stringValue = preset?.reverbName ?? (preset != nil ? "- EMPTY -" : "")
    }
    
}
