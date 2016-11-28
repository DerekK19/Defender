//
//  PedalVC.swift
//  DefenderApp
//
//  Created by Derek Knight on 28/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class PedalVC: UIViewController {

    @IBOutlet weak var slot: UIView!
    @IBOutlet weak var bodyTop: UIView!
    @IBOutlet weak var bodyBottom: UIView!
    @IBOutlet weak var upperKnobs: UIStackView!
    @IBOutlet weak var lowerKnobs: UIStackView!
    @IBOutlet weak var knobUpperLeft: UIView!
    @IBOutlet weak var knobUpperMiddle: UIView!
    @IBOutlet weak var knobUpperRight: UIView!
    @IBOutlet weak var knobLowerLeft: UIView!
    @IBOutlet weak var knobLowerMiddle: UIView!
    @IBOutlet weak var knobLowerRight: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
