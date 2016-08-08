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
    @IBOutlet weak var gainArrow: NSImageView!
    @IBOutlet weak var volumeArrow: NSImageView!
    @IBOutlet weak var trebleArrow: NSImageView!
    @IBOutlet weak var middleArrow: NSImageView!
    @IBOutlet weak var bassArrow: NSImageView!
    @IBOutlet weak var reverbArrow: NSImageView!
    @IBOutlet weak var gainKnob: KnobControl!
    @IBOutlet weak var volumeKnob: KnobControl!
    @IBOutlet weak var trebleKnob: KnobControl!
    @IBOutlet weak var middleKnob: KnobControl!
    @IBOutlet weak var bassKnob: KnobControl!
    @IBOutlet weak var reverbKnob: KnobControl!
    
    var presets = [DTOPreset] ()
    
    var amplifiers = [DTOAmplifier]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        amplifierList.removeAllItems()
        presetList.removeAllItems()

        amplifiers = Mustang().getConnectedAmplifiers()
        amplifierList.addItemsWithTitles(amplifiers.map( { $0.name } ))
        gainArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
        volumeArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
        trebleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
        middleArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
        bassArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
        reverbArrow.image = NSImage(named: "down-arrow")?.imageWithTintColor(NSColor.whiteColor())
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func willOpenAmplifier(sender: AnyObject) {
        if let amplifier = amplifiers.filter( { $0.name == amplifierList.title}).first {
            Mustang().getPresets(amplifier) { (presets) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presets = presets
                    self.presetList.removeAllItems()
                    self.presetList.addItemsWithTitles(presets.map( { $0.name } ))
                    self.presetList.selectItemAtIndex(0)
                    self.didClickPreset(self.presetList)
                }
            }
        }
    }

    @IBAction func didClickPreset(sender: AnyObject) {
        
        let preset = presets[presetList.indexOfSelectedItem]
        if let gain = preset.gain1 {
            NSLog("Gain: \(gain)")
            gainKnob.floatValue = gain
        } else {
            gainKnob.floatValue = 1.0
        }
        if let volume = preset.volume {
            NSLog("Volume: \(volume)")
            volumeKnob.floatValue = volume
        } else {
            volumeKnob.floatValue = 1.0
        }
        if let treble = preset.treble {
            NSLog("Treble: \(treble)")
            trebleKnob.floatValue = treble
        } else {
            trebleKnob.floatValue = 1.0
        }
        if let middle = preset.middle {
            NSLog("Middle: \(middle)")
            middleKnob.floatValue = middle
        } else {
            middleKnob.floatValue = 1.0
        }
        if let bass = preset.bass {
            NSLog("Bass: \(bass)")
            bassKnob.floatValue = bass
        } else {
            bassKnob.floatValue = 1.0
        }
        if let presence = preset.presence {
            NSLog("Reverb/Presence: \(presence)")
            reverbKnob.floatValue = presence
        } else {
            reverbKnob.floatValue = 1.0
        }
    }
    
    @IBAction func didChangeGain(sender: AnyObject) {
        NSLog("New gain is \(gainKnob.floatValue)")
    }
    
    @IBAction func didChangeVolume(sender: AnyObject) {
        NSLog("New volume is \(volumeKnob.floatValue)")
    }
    
    @IBAction func didChangeTreble(sender: AnyObject) {
        NSLog("New treble is \(trebleKnob.floatValue)")
    }
    
    @IBAction func didChangeMiddle(sender: AnyObject) {
        NSLog("New middle is \(middleKnob.floatValue)")
    }
    
    @IBAction func didChangeBass(sender: AnyObject) {
        NSLog("New bass is \(bassKnob.floatValue)")
    }
    
    @IBAction func didChangeReverb(sender: AnyObject) {
        NSLog("New reverb is \(reverbKnob.floatValue)")
    }
}

