//
//  ViewController.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class MainVC: NSViewController {

    @IBOutlet weak var amplifierList: NSPopUpButton!
    @IBOutlet weak var presetList: NSPopUpButton!
    @IBOutlet weak var openButton: NSButton!
    
    var amplifiers = [DTOAmplifier]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        amplifierList.removeAllItems()
        presetList.removeAllItems()

        amplifiers = Mustang().getConnectedAmplifiers()
        amplifierList.addItemsWithTitles(amplifiers.map( { $0.name } ))
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func willOpenAmplifier(sender: AnyObject) {
        if let amplifier = amplifiers.filter( { $0.name == amplifierList.title}).first {
            Mustang().getPresets(amplifier) { (presets) in
                self.presetList.removeAllItems()
                self.presetList.addItemsWithTitles(presets.map( { $0.name } ))
            }
        }
    }

}

