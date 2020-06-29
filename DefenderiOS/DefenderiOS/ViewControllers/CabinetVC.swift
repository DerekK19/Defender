//
//  CabinetVC.swift
//  DefenderiOS
//
//  Created by Derek Knight on 28/06/20.
//  Copyright © 2020 Derek Knight. All rights reserved.
//

import UIKit

protocol CabinetVCDelegate {
    func settingsDidChangeForCabinet(_ sender: CabinetVC, slotNumber: Int, effect: DXEffect)
}

class CabinetVC: BaseEffectVC {

    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var powerLED: LEDControl!
    @IBOutlet weak var cabinetImage: UIImageView!

    var slotNumber: Int?
    var cabinet: Int?
    var module: Int?

    var delegate: CabinetVCDelegate?
    
    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0),
                                      2 : UIColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0),
                                      10 : UIColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0),
                                      14 : UIColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)]

    var fullBackgroundColour = UIColor.black
    var pedalBackgroundColour = UIColor.black

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = UIColor()
            switch state {
            case .initial:
                break
            case .disabled:
                newBackgroundColour = UIColor.slotBackground
                powerLED.backgroundColour = UIColor.slotBackground
                slotLabel.isHidden = false
            case .off:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red.withBrightness(0.5)
            case .on:
                newBackgroundColour = fullBackgroundColour
                slotLabel.isHidden = true
                powerLED.backgroundColour = UIColor.red
            }
            pedalBackgroundColour = newBackgroundColour
            let currentState = powerState
            powerState = currentState
        }
    }
    
    internal func configureWith(preset: DXPreset?) {
        self.cabinet = preset?.cabinet
        self.module = preset?.module
        fullBackgroundColour = UIColor.slotBackground
        if appeared {
            if slotNumber != nil { slotLabel.text = "\(slotNumber! + 1)" } else { slotLabel.text = "" }
            if module == nil {
                state = .disabled
            } else {
                state = .on //(module?.enabled ?? false) ? .on : .off
            }
            if let cabinet = cabinet, let module = module {
                cabinetImage.image = UIImage(named: "cabinet-\(cabinet)\(module)")
                if cabinetImage.image == nil {
                    switch module {
                    case 83:
                        cabinetImage.image = UIImage(named: "cabinet-383")
                    case 93:
                        cabinetImage.image = UIImage(named: "cabinet-1093")
                    case 94:
                        cabinetImage.image = UIImage(named: "cabinet-694")
                    case 97:
                        cabinetImage.image = UIImage(named: "cabinet-797")
                    case 100:
                        cabinetImage.image = UIImage(named: "cabinet-2100")
                    case 103:
                        cabinetImage.image = UIImage(named: "cabinet-1103")
                    case 106:
                        cabinetImage.image = UIImage(named: "cabinet-4106")
                    case 109:
                        cabinetImage.image = UIImage(named: "cabinet-8109")
                    case 114:
                        cabinetImage.image = UIImage(named: "cabinet-12114")
                    case 117:
                        cabinetImage.image = UIImage(named: "cabinet-9117")
                    case 121:
                        cabinetImage.image = UIImage(named: "cabinet-8121")
                    case 124:
                        cabinetImage.image = UIImage(named: "cabinet-5124")
                    case 241:
                        cabinetImage.image = UIImage(named: "cabinet-10241")
                    case 246:
                        cabinetImage.image = UIImage(named: "cabinet-9246")
                    case 249:
                        cabinetImage.image = UIImage(named: "cabinet-1249")
                    case 252:
                        cabinetImage.image = UIImage(named: "cabinet-8252")
                    case 255:
                        cabinetImage.image = UIImage(named: "cabinet-10255")
                    default:
                        cabinetImage.image = nil
                    }
                }
            } else {
                cabinetImage.image = nil
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
