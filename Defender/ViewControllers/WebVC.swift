//
//  WebVC.swift
//  Defender
//
//  Created by Derek Knight on 7/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class WebVC: NSViewController {

    @IBOutlet weak var slot: WebSlotControl!
    @IBOutlet weak var shade: ShadeControl!

    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var countLabel: NSTextField!
    
    @IBOutlet weak var loginButton: NSButton!
    
    @IBOutlet weak var searchTextField: NSTextField!
    
    @IBOutlet weak var searchButton: NSButton!
    
    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    var fullBackgroundColour = NSColor.black
    var webBackgroundColour = NSColor.black

    var state: EffectState = .disabled {
        didSet {
            var newBackgroundColour = NSColor()
            switch state {
            case .disabled:
                newBackgroundColour = slotBackgroundColour
            case .off:
                newBackgroundColour = fullBackgroundColour
            case .on:
                newBackgroundColour = fullBackgroundColour
            }
            self.slot.backgroundColour = newBackgroundColour
            self.webBackgroundColour = newBackgroundColour
            let currentState = self.powerState
            self.powerState = currentState
        }
    }
    
    var powerState: PowerState = .off {
        didSet {
            self.shade.isOpen = powerState == .on || state == .disabled
        }
    }
    
    internal var ampController: AmpController?
    
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
    }

    // MARK: Action functions
    
    @IBAction func willLogin(_ sender: NSButton) {
        self.resignFirstResponder()
        if loginButton.title == "Log out" {
            ampController?.logout {(loggedOut: Bool) in
                self.loginButton.title = loggedOut ? "Log in" : "Log out"
                
            }
        } else {
            ampController?.login(username: usernameTextField.stringValue,
                                password: passwordTextField.stringValue)
            { (loggedIn: Bool) in
                self.loginButton.title = loggedIn ? "Log out" : "Login"
            }
        }
    }
    
    @IBAction func wilSearch(_ sender: NSButton) {
        self.resignFirstResponder()
        ampController?.search(forTitle: searchTextField.stringValue)
        { (response: DTOSearchResponse?) in
            if let items = response?.items {
                self.countLabel.stringValue = "Found \(items.count) items"
                NSLog("Found \(items.count) items")
                for item in items {
                    NSLog("\(item.title) - \(item.data?.preset?.effects.count ?? 0) effects")
                }
            }
        }
    }
    
}
