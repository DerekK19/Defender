//
//  PedalVC.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang
import Flogger

protocol PedalVCDelegate {
    func settingsDidChangeForPedal(_ sender: PedalVC)
}

class PedalVC: NSViewController {

    @IBOutlet weak var slot: EffectSlotControl!
    @IBOutlet weak var pedalLead: NSBox!
    @IBOutlet weak var bodyTop: PedalBodyControl!
    @IBOutlet weak var bodyBottom: PedalBodyControl!
    @IBOutlet weak var pad: PedalPadControl!
    @IBOutlet weak var pedalLogo: NSImageView!
    @IBOutlet weak var typeLabel: NSTextField!
    @IBOutlet weak var textBar: NSBox!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var upperKnobs: NSStackView!
    @IBOutlet weak var lowerKnobs: NSStackView!
    @IBOutlet weak var knobUpperLeft: PedalKnobControl!
    @IBOutlet weak var knobUpperMiddle: PedalKnobControl!
    @IBOutlet weak var knobUpperRight: PedalKnobControl!
    @IBOutlet weak var knobLowerLeft: PedalKnobControl!
    @IBOutlet weak var knobLowerMiddle: PedalKnobControl!
    @IBOutlet weak var knobLowerRight: PedalKnobControl!
    @IBOutlet weak var shade: ShadeControl!
    
    var effect: DTOEffect?
    
    var delegate: PedalVCDelegate?
    
    let slotBackgroundColour = NSColor.slotBackground
    let bgColours: [Int : NSColor] = [1 : NSColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0),
                                      2 : NSColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0),
                                      10 : NSColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0),
                                      14 : NSColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)]
    
    var fullBackgroundColour = NSColor.black
    var pedalBackgroundColour = NSColor.black
    
    var upperLeftIndex: Int? = 0
    var upperMiddleIndex: Int? = 0
    var upperRightIndex: Int? = 0
    var lowerLeftIndex: Int? = 0
    var lowerMiddleIndex: Int? = 0
    var lowerRightIndex: Int? = 0
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            self.knobUpperLeft.alphaValue = state == .disabled ? 0.0 : 1.0
            self.knobUpperMiddle.alphaValue = state == .disabled ? 0.0 : 1.0
            self.knobUpperRight.alphaValue = state == .disabled ? 0.0 : 1.0
            self.knobLowerLeft.alphaValue = state == .disabled ? 0.0 : 1.0
            self.knobLowerMiddle.alphaValue = state == .disabled ? 0.0 : 1.0
            self.knobLowerRight.alphaValue = state == .disabled ? 0.0 : 1.0
            self.pedalLogo.alphaValue = state == .disabled ? 0.0 : 1.0
            switch state {
            case .disabled:
                newBackgroundColour = NSColor.clear
                self.powerLED.backgroundColour = NSColor.black
            case .off:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                self.powerLED.backgroundColour = NSColor.red
            }
            self.slot.backgroundColour = slotBackgroundColour
            self.pedalBackgroundColour = newBackgroundColour
            self.pedalLead.borderColor = NSColor.lead
            self.bodyTop.backgroundColour = newBackgroundColour
            self.bodyBottom.backgroundColour = newBackgroundColour
            let currentState = self.powerState
            self.powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            self.shade.isOpen = powerState == .on || state == .disabled
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
        self.state = .disabled
        self.typeLabel.stringValue = ""
        self.nameLabel.stringValue = ""
        
        knobUpperLeft.delegate = self
        knobUpperMiddle.delegate = self
        knobUpperRight.delegate = self
        knobLowerLeft.delegate = self
        knobLowerMiddle.delegate = self
        knobLowerRight.delegate = self
    }
    
    func configureWithPedal(_ pedal: DTOEffect?) {
        effect = pedal
        delegate = nil
        typeLabel.stringValue = pedal?.type.rawValue.uppercased() ?? ""
        nameLabel.stringValue = pedal?.name?.uppercased() ?? ""
        fullBackgroundColour = bgColours[pedal?.colour ?? 0] ?? slotBackgroundColour
        if pedal == nil {
            state = .disabled
        } else {
            state = (pedal?.enabled ?? false) ? .on : .off
        }
        upperKnobs.isHidden = false
        lowerKnobs.isHidden = false

        upperLeftIndex = nil
        upperMiddleIndex = nil
        upperRightIndex = nil
        lowerLeftIndex = nil
        lowerMiddleIndex = nil
        lowerRightIndex = nil
        
        if pedal?.knobCount == 1 {
            lowerKnobs.isHidden = true
            upperMiddleIndex = 0
        } else if pedal?.knobCount == 2 {
            lowerKnobs.isHidden = true
            upperLeftIndex = 0
            upperRightIndex = 1
        } else if pedal?.knobCount == 3 {
            lowerKnobs.isHidden = true
            upperLeftIndex = 0
            upperMiddleIndex = 1
            upperRightIndex = 2
        } else if pedal?.knobCount == 4 {
            upperLeftIndex = 0
            upperRightIndex = 1
            lowerLeftIndex = 2
            lowerRightIndex = 3
        } else if pedal?.knobCount == 5 {
            upperLeftIndex = 0
            upperMiddleIndex = 1
            upperRightIndex = 2
            lowerLeftIndex = 3
            lowerRightIndex = 4
        } else if pedal?.knobCount == 6 {
            upperLeftIndex = 0
            upperMiddleIndex = 1
            upperRightIndex = 2
            lowerLeftIndex = 3
            lowerMiddleIndex = 4
            lowerRightIndex = 5
        }
//        viewUpperLeft.isHidden = upperLeftIndex == nil
        knobUpperLeft.isHidden = upperLeftIndex == nil
//        labelUpperLeft.isHidden = upperLeftIndex == nil
//        viewUpperMiddle.isHidden = upperMiddleIndex == nil
        knobUpperMiddle.isHidden = upperMiddleIndex == nil
//        labelUpperMiddle.isHidden = upperMiddleIndex == nil
//        viewUpperRight.isHidden = upperRightIndex == nil
        knobUpperRight.isHidden = upperRightIndex == nil
//        labelUpperRight.isHidden = upperRightIndex == nil
//        viewLowerLeft.isHidden = lowerLeftIndex == nil
        knobLowerLeft.isHidden = lowerLeftIndex == nil
//        labelLowerLeft.isHidden = lowerLeftIndex == nil
//        viewLowerMiddle.isHidden = lowerMiddleIndex == nil
        knobLowerMiddle.isHidden = lowerMiddleIndex == nil
//        labelLowerMiddle.isHidden = lowerMiddleIndex == nil
//        viewLowerRight.isHidden = lowerRightIndex == nil
        knobLowerRight.isHidden = lowerRightIndex == nil
//        labelLowerRight.isHidden = lowerRightIndex == nil
        
        if let index = upperLeftIndex {
            knobUpperLeft.floatValue = pedal?.knobs[index].value ?? 0
//            labelUpperLeft.text = pedal?.knobs[index].name
        }
        if let index = upperMiddleIndex {
            knobUpperMiddle.floatValue = pedal?.knobs[index].value ?? 0
//            labelUpperMiddle.text = pedal?.knobs[index].name
        }
        if let index = upperRightIndex {
            knobUpperRight.floatValue = pedal?.knobs[index].value ?? 0
//            labelUpperRight.text = pedal?.knobs[index].name
        }
        if let index = lowerLeftIndex {
            knobLowerLeft.floatValue = pedal?.knobs[index].value ?? 0
//            labelLowerLeft.text = pedal?.knobs[index].name
        }
        if let index = lowerMiddleIndex {
            knobLowerMiddle.floatValue = pedal?.knobs[index].value ?? 0
//            labelLowerMiddle.text = pedal?.knobs[index].name
        }
        if let index = lowerRightIndex {
            knobLowerRight.floatValue = pedal?.knobs[index].value ?? 0
//            labelLowerRight.text = pedal?.knobs[index].name
        }
    }
    
}


extension PedalVC: PedalKnobDelegate {
    
    func valueDidChangeForKnob(_ sender: PedalKnobControl, value: Float) {
        if effect != nil {
            var currentValue: Float?
            switch sender {
            case knobUpperLeft:
                currentValue = effect!.knobs[0].value
            case knobUpperMiddle:
                currentValue = effect!.knobs[1].value
            case knobUpperRight:
                currentValue = effect!.knobs[2].value
            case knobLowerLeft:
                currentValue = effect!.knobs[3].value
            case knobLowerMiddle:
                currentValue = effect!.knobs[4].value
            case knobLowerRight:
                currentValue = effect!.knobs[5].value
            default:
                Flogger.log.error("Don't know what knob sent this event")
            }

            if value != currentValue {
                switch sender {
                case knobUpperLeft:
                    Flogger.log.debug("New upper left knob is \(value)")
                    effect!.knobs[0].value = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobUpperMiddle:
                    Flogger.log.debug("New upper middle knob is \(value)")
                    effect!.knobs[1].value = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobUpperRight:
                    Flogger.log.debug("New upper right knob is \(value)")
                    effect!.knobs[2].value = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerLeft:
                    Flogger.log.debug("New lower left knob is \(value)")
                    effect!.knobs[3].value = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerMiddle:
                    Flogger.log.debug("New lower middle knob is \(value)")
                    effect!.knobs[4].value = value
                    delegate?.settingsDidChangeForPedal(self)
                case knobLowerRight:
                    Flogger.log.debug("New lower right knob is \(value)")
                    effect!.knobs[5].value = value
                    delegate?.settingsDidChangeForPedal(self)
                default:
                    Flogger.log.error("Don't know what knob sent this event")
                }
            }
        } else {
            Flogger.log.error("Can't get a knob change if there is no pedal")
        }
    }
}

