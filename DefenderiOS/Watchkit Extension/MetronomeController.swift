//
//  MetronomeController.swift
//  DefenderApp
//
//  Created by Derek Knight on 4/02/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import WatchKit
import Foundation

class MetronomeController: WKInterfaceController {

    @IBOutlet weak var bpmLabel: WKInterfaceLabel!
    @IBOutlet weak var bpmSlider: WKInterfaceSlider!
    @IBOutlet weak var bpmButton: WKInterfaceButton!
    
    private var currentBPM: Int = 60
    private var metronomeNowRunning: Bool = false
    private var metronomeTimer: Timer?
        
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func bpmSliderChanged(value: Float) {
        currentBPM = Int(round(value))
        bpmLabel.setText("\(currentBPM) bpm")
    }
    
    @IBAction func didPressBPM() {
        metronomeNowRunning = !metronomeNowRunning
        
        if metronomeNowRunning {
            bpmButton.setTitle("Stop")
            let beatInterval = TimeInterval(currentBPM / 60)
            metronomeTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { _ in
                WKInterfaceDevice().play(.start)
            }
        } else {
            metronomeTimer?.invalidate()
            metronomeTimer = nil
            bpmButton.setTitle("Start")
        }
    }
    
}
