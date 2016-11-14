//
//  ViewController.swift
//  DefenderApp
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import RemoteDefender

class ViewController: UIViewController {

    var central = Central()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        central.start()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        central.scan()
    }
    
    deinit {
        central.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

