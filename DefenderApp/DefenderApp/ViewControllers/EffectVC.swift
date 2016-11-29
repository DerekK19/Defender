//
//  EffectVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class EffectVC: UIViewController {

    let slotBackgroundColour = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let bgColours: [Int : UIColor] = [1 : UIColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0),
                                      2 : UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0),
                                      10 : UIColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0),
                                      14 : UIColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)]
    
    var fullBackgroundColour = UIColor.black
    var effectBackgroundColour = UIColor.black
    
    var slotNumber: Int?
    var effect: DXEffect?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        NSLog("Appearing slot \(effect?.slot) \(fullBackgroundColour)")
        view.backgroundColor = fullBackgroundColour
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func configureWith(effect: DXEffect?) {
        self.effect = effect
        fullBackgroundColour = bgColours[effect?.colour ?? 0] ?? slotBackgroundColour
    }
}
