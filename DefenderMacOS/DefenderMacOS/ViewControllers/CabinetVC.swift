//
//  CabinetVC.swift
//  Defender
//
//  Created by Derek Knight on 14/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Flogger

protocol CabinetVCDelegate {
    func settingsDidChangeForCabinet(_ sender: CabinetVC)
}

class CabinetVC: NSViewController {
    
    @IBOutlet weak var slot: CabinetSlotControl!
    @IBOutlet weak var effectLead: NSBox!
    @IBOutlet weak var pedalLead: NSBox!
    @IBOutlet weak var cabinet: CabinetControl!
    @IBOutlet weak var cabinetImage: NSImageView!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var shade: ShadeControl!
    
    var delegate: CabinetVCDelegate?
    
    let slotBackgroundColour = NSColor.slotBackground
    let bgColours: [Int : NSColor] = [1 : NSColor.purpleEffect,
                                      2 : NSColor.greyEffect,
                                      10 : NSColor.blueEffect,
                                      14 : NSColor.greenEffect]
    
    var fullBackgroundColour = NSColor.black
    var cabinetBackgroundColour = NSColor.black
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
                powerLED.backgroundColour = NSColor.black
            case .off:
                newBackgroundColour = fullBackgroundColour
                powerLED.backgroundColour = NSColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                powerLED.backgroundColour = NSColor.red
            }
            slot.backgroundColour = slotBackgroundColour
            cabinetBackgroundColour = newBackgroundColour
            effectLead.borderColor = NSColor.lead
            pedalLead.borderColor = NSColor.lead
            let currentState = powerState
            powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            shade.isOpen = powerState == .on || state == .disabled
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
        super.viewDidLoad()
        state = .disabled
    }
    
    func configureWithPreset(_ preset: BOPreset?) {
        delegate = nil
        fullBackgroundColour = slotBackgroundColour
        cabinet.isHidden = preset != nil
        if let preset = preset {
            state = (preset.cabinet != nil) ? .on : .off
            switch preset.module ?? 0 {
            case 83:
                cabinetImage.image = NSImage(named: "cabinet-383")
            case 93:
                cabinetImage.image = NSImage(named: "cabinet-1093")
            case 94:
                cabinetImage.image = NSImage(named: "cabinet-694")
            case 97:
                cabinetImage.image = NSImage(named: "cabinet-797")
            case 100:
                cabinetImage.image = NSImage(named: "cabinet-2100")
            case 103:
                cabinetImage.image = NSImage(named: "cabinet-1103")
            case 106:
                cabinetImage.image = NSImage(named: "cabinet-4106")
            case 109:
                cabinetImage.image = NSImage(named: "cabinet-8109")
            case 114:
                cabinetImage.image = NSImage(named: "cabinet-12114")
            case 117:
                cabinetImage.image = NSImage(named: "cabinet-9117")
            case 121:
                cabinetImage.image = NSImage(named: "cabinet-8121")
            case 124:
                cabinetImage.image = NSImage(named: "cabinet-5124")
            case 241:
                cabinetImage.image = NSImage(named: "cabinet-241")
            case 246:
                cabinetImage.image = NSImage(named: "cabinet-9246")
            case 249:
                cabinetImage.image = NSImage(named: "cabinet-1249")
            case 252:
                cabinetImage.image = NSImage(named: "cabinet-8252")
            case 255:
                cabinetImage.image = NSImage(named: "cabinet-10255")
            default:
                cabinetImage.image = nil
            }
        } else {
            state = .disabled
            cabinet.isHidden = false
        }
    }
}
