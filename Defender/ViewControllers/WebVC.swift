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
    
    @IBOutlet weak var searchResultsScrollView: NSScrollView!
    @IBOutlet weak var searchResultsTableView: NSTableView!
    
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
    
    var loggedIn: Bool = false {
        didSet {
            self.loginButton.title = self.loggedIn ? "Log out" : "Log in"
            self.usernameTextField.isHidden = loggedIn
            self.passwordTextField.isHidden = loggedIn
            self.searchButton.isHidden = !loggedIn
            self.searchTextField.isHidden = !loggedIn
            self.searchResultsScrollView.isHidden = !loggedIn
        }
    }
    
    internal var ampController: AmpController?
    fileprivate var presets = [DTOSearchItem]()
    
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
        self.loggedIn = false
    }

    // MARK: Action functions
    
    @IBAction func willLogin(_ sender: NSButton) {
        self.resignFirstResponder()
        if loggedIn {
            ampController?.logout {(loggedOut: Bool) in
                self.loggedIn = !loggedOut
            }
        } else {
            ampController?.login(username: usernameTextField.stringValue,
                                password: passwordTextField.stringValue)
            { (loggedIn: Bool) in
                self.loggedIn = loggedIn
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
                self.presets = items
                self.searchResultsTableView.reloadData()
            }
        }
    }
    
}

extension WebVC: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presets.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var result: NSTextField? = tableView.make(withIdentifier: "MyView", owner: self) as! NSTextField?
        if result == nil {
            result = NSTextField(frame: NSMakeRect(0, 0, 100, 20))
            result?.identifier = "MyView"
        }
        result?.stringValue = presets[row].title
        return result
    }

}
