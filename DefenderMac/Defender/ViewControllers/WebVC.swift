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
    
    @IBOutlet weak var loginButton: ActionButtonControl!
    
    @IBOutlet weak var searchTextField: NSTextField!
    
    @IBOutlet weak var searchButton: ActionButtonControl!
    
    @IBOutlet weak var searchResultsScrollView: NSScrollView!
    @IBOutlet weak var searchResultsTableView: NSTableView!
    
    @IBOutlet weak var leftArrow: ArrowButtonControl!
    @IBOutlet weak var page1Arrow: ArrowButtonControl!
    @IBOutlet weak var page2Arrow: ArrowButtonControl!
    @IBOutlet weak var page3Arrow: ArrowButtonControl!
    @IBOutlet weak var page4Arrow: ArrowButtonControl!
    @IBOutlet weak var page5Arrow: ArrowButtonControl!
    @IBOutlet weak var rightArrow: ArrowButtonControl!

    var webColumn1: WebHeaderCell?

    var delegate: WebVCDelegate?
    
    let slotBackgroundColour = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    var fullBackgroundColour = NSColor.black
    var webBackgroundColour = NSColor.black

    var newPage: UInt = 1
    var pagination: DTOSearchPagination?
    
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
            self.loginButton.powerState = .on // powerState
            self.searchButton.powerState = .on // powerState
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
            self.pagination = nil
            self.presets = [DTOSearchItem]()
            self.searchResultsTableView.reloadData()
        }
    }
    
    var searched: Bool = false {
        didSet {
            self.leftArrow.isHidden = !searched
            self.page1Arrow.isHidden = !searched
            self.page2Arrow.isHidden = !searched
            self.page3Arrow.isHidden = !searched
            self.page4Arrow.isHidden = !searched
            self.page5Arrow.isHidden = !searched
            self.rightArrow.isHidden = !searched
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
        search(forPage: 1)
    }
    
    @IBAction func didPressArrow(sender: NSButton) {
        if let pagination = self.pagination {
            let firstPage = (UInt(pagination.page / 5) * 5) + 1
            var nextPage = newPage
            switch sender {
            case leftArrow:
                if firstPage > 5 { nextPage = firstPage-5 }
                break
            case page1Arrow:
                nextPage = firstPage
                break
            case page2Arrow:
                nextPage = min(firstPage+1, pagination.pages)
                break
            case page3Arrow:
                nextPage = min(firstPage+2, pagination.pages)
                break
            case page4Arrow:
                nextPage = min(firstPage+3, pagination.pages)
                break
            case page5Arrow:
                nextPage = min(firstPage+4, pagination.pages)
                break
            case rightArrow:
                nextPage = min(firstPage+5, pagination.pages)
                break
            default:
                fatalError("There are only left and right arrows")
            }
            if nextPage != newPage {
                search(forPage: nextPage)
            }
        }
    }
    
    // MARK: Private functions
    private func customiseTableView() {
        if searchResultsTableView.tableColumns.count > 0 {
            webColumn1 = WebHeaderCell(textCell: "Preset Name")
            searchResultsTableView.tableColumns[0].headerCell = webColumn1!
        }
    }
    
    private func configureArrows() {
        if let pagination = self.pagination {
            let firstPage = (UInt(pagination.page / 5) * 5) + 1            
            configureArrow(arrow: leftArrow, showIf: firstPage > 1, title: "<")
            configureArrow(arrow: page1Arrow, pageNumber: firstPage)
            configureArrow(arrow: page2Arrow, pageNumber: firstPage+1)
            configureArrow(arrow: page3Arrow, pageNumber: firstPage+2)
            configureArrow(arrow: page4Arrow, pageNumber: firstPage+3)
            configureArrow(arrow: page5Arrow, pageNumber: firstPage+4)
            configureArrow(arrow: rightArrow, showIf: firstPage+5 <= pagination.pages, title: ">")
        }
    }
    
    private func configureArrow(arrow: ArrowButtonControl, pageNumber: UInt) {
        if let pagination = self.pagination {
            arrow.title = pageNumber <= pagination.pages ? "\(pageNumber)" : ""
            arrow.setState(arrow.title == "" ? .inactive : pageNumber == pagination.page ? .current : .active)
        }
    }
    
    private func configureArrow(arrow: ArrowButtonControl, showIf show: Bool, title: String) {
        if let _ = self.pagination {
            arrow.title = show ? title : ""
            arrow.setState(arrow.title == "" ? .inactive : .active)
        }
    }
    
    private func search(forPage page: UInt) {
        ampController?.search(forTitle: searchTextField.stringValue,
                              pageNumber: page,
                              maxReturn: 10)
        { (response: DTOSearchResponse?) in
            if let response = response {
                let items = response.items
                self.pagination = response.pagination
                self.newPage = self.pagination!.page
                self.countLabel.stringValue = "Found \(self.pagination!.total) items"
                NSLog("For page \(self.newPage), found \(self.pagination!.total) items. Page \(self.pagination!.page) of \(self.pagination!.pages). Limit \(self.pagination!.limit) per page")
                for item in items {
                    NSLog("\(item.title) - \(item.data?.preset?.effects.count ?? 0) effects")
                }
                self.presets = items
                self.searched = true
                self.configureArrows()
                self.searchResultsTableView.reloadData()
            }
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
