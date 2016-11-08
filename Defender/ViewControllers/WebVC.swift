//
//  WebVC.swift
//  Defender
//
//  Created by Derek Knight on 7/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

protocol WebVCDelegate {
    func didSelectPreset(preset: DTOPreset?)
}

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
    
    @IBOutlet weak var bigLeftArrow: NSButton!
    @IBOutlet weak var leftArrow: NSButton!
    @IBOutlet weak var rightArrow: NSButton!
    @IBOutlet weak var bigRightArrow: NSButton!

    var webColumn1: WebHeaderCell?

    var delegate: WebVCDelegate?
    
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
            self.webColumn1?.backgroundColour = newBackgroundColour
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
            self.searched = false
            self.presets = [DTOSearchItem]()
            self.searchResultsTableView.reloadData()
        }
    }
    
    var searched: Bool = false {
        didSet {
            self.bigLeftArrow.isHidden = !searched
            self.leftArrow.isHidden = !searched
            self.rightArrow.isHidden = !searched
            self.bigRightArrow.isHidden = !searched
            self.countLabel.isHidden = !searched
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
        self.customiseTableView()
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
    
    @IBAction func willSearch(_ sender: NSButton) {
        self.resignFirstResponder()
        ampController?.search(forTitle: searchTextField.stringValue,
                              pageNumber: 1,
                              maxReturn: 10)
        { (response: DTOSearchResponse?) in
            if let response = response {
                let items = response.items
                let pagination = response.pagination
                self.countLabel.stringValue = "Found \(pagination.total) items"
                NSLog("Found \(pagination.total) items. Page \(pagination.page) of \(pagination.pages). Limit \(pagination.limit) per page")
                for item in items {
                    NSLog("\(item.title) - \(item.data?.preset?.effects.count ?? 0) effects")
                }
                self.presets = items
                self.searched = true
                self.searchResultsTableView.reloadData()
            }
        }
    }
    
    @IBAction func didPressArrow(sender: NSButton) {
        switch sender {
        case bigLeftArrow:
            break
        case leftArrow:
            break
        case rightArrow:
            break
        case bigRightArrow:
            break
        default:
            fatalError("There are only left and right arrows")
        }
    }
    
    // MARK: Private functions
    private func customiseTableView() {
        if searchResultsTableView.tableColumns.count > 0 {
            webColumn1 = WebHeaderCell(textCell: "Preset Name")
            searchResultsTableView.tableColumns[0].headerCell = webColumn1!
        }
    }
}

extension WebVC: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presets.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let item = presets[row]
        return item.title
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        NSLog("Selection changed")
        let row = searchResultsTableView.selectedRow
        if row >= 0 && row < presets.count {
            let item = presets[row]
            delegate?.didSelectPreset(preset: item.data?.preset)
        }
    }
}
