//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import BluetoothKit
import CoreBluetooth

internal class CentralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BKCentralDelegate, AvailabilityViewController, RemotePeripheralViewControllerDelegate {

    // MARK: Properties

    internal var availabilityView = AvailabilityView()

    private var activityIndicator: UIActivityIndicatorView? {
        guard let activityIndicator = activityIndicatorBarButtonItem.customView as? UIActivityIndicatorView else {
            return nil
        }
        return activityIndicator
    }

    private let activityIndicatorBarButtonItem = UIBarButtonItem(customView: UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white))
    private let discoveriesTableView = UITableView()
    private var discoveries = [BKDiscovery]()
    private let discoveriesTableViewCellIdentifier = "Discoveries Table View Cell Identifier"
    private let central = BKCentral()

    // MARK: UIViewController Life Cycle

    internal override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        activityIndicator?.color = UIColor.black
        navigationItem.title = "Central"
        navigationItem.rightBarButtonItem = activityIndicatorBarButtonItem
        applyAvailabilityView()
        discoveriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: discoveriesTableViewCellIdentifier)
        discoveriesTableView.dataSource = self
        discoveriesTableView.delegate = self
        view.addSubview(discoveriesTableView)
        applyConstraints()
        startCentral()
    }

    internal override func viewDidAppear(_ animated: Bool) {
        scan()
    }

    internal override func viewWillDisappear(_ animated: Bool) {
        central.interruptScan()
    }

    deinit {
        _ = try? central.stop()
    }

    // MARK: Functions

    private func applyConstraints() {
        discoveriesTableView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(availabilityView.snp.top)
        }
    }

    private func startCentral() {
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)
            let dataServiceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let dataServiceCharacteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let configuration = BKConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch let error {
            print("Error while starting: \(error)")
        }
    }

    private func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            let indexPathsToRemove = changes.filter({ $0 == .remove(discovery: nil) }).map({ IndexPath(row: self.discoveries.index(of: $0.discovery)!, section: 0) })
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .insert(discovery: nil) }).map({ IndexPath(row: self.discoveries.index(of: $0.discovery)!, section: 0) })
            if !indexPathsToRemove.isEmpty {
                self.discoveriesTableView.deleteRows(at: indexPathsToRemove, with: UITableViewRowAnimation.automatic)
            }
            if !indexPathsToInsert.isEmpty {
                self.discoveriesTableView.insertRows(at: indexPathsToInsert, with: UITableViewRowAnimation.automatic)
            }
            for insertedDiscovery in changes.filter({ $0 == .insert(discovery: nil) }) {
                Logger.log("Discovery: \(insertedDiscovery)")
            }
        }, stateHandler: { newState in
            if newState == .scanning {
                self.activityIndicator?.startAnimating()
                return
            } else if newState == .stopped {
                self.discoveries.removeAll()
                self.discoveriesTableView.reloadData()
            }
            self.activityIndicator?.stopAnimating()
        }, errorHandler: { error in
            Logger.log("Error from scanning: \(error)")
        })
    }

    // MARK: UITableViewDataSource

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: discoveriesTableViewCellIdentifier, for: indexPath)
        let discovery = discoveries[indexPath.row]
        cell.textLabel?.text = discovery.localName != nil ? discovery.localName : discovery.remotePeripheral.name
        return cell
    }

    // MARK: UITableViewDelegate

    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        central.connect(remotePeripheral: discoveries[indexPath.row].remotePeripheral) { remotePeripheral, error in
            tableView.isUserInteractionEnabled = true
            guard error == nil else {
                print("Error connecting peripheral: \(error)")
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let remotePeripheralViewController = RemotePeripheralViewController(central: self.central, remotePeripheral: remotePeripheral)
            remotePeripheralViewController.delegate = self
            self.navigationController?.pushViewController(remotePeripheralViewController, animated: true)
        }
    }

    // MARK: BKAvailabilityObserver

    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        availabilityView.availabilityObserver(availabilityObservable, availabilityDidChange: availability)
        if availability == .available {
            scan()
        } else {
            central.interruptScan()
        }
    }

    // MARK: BKCentralDelegate

    internal func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        Logger.log("Remote peripheral did disconnect: \(remotePeripheral)")
        _ = self.navigationController?.popToViewController(self, animated: true)
    }

    // MARK: RemotePeripheralViewControllerDelegate

    internal func remotePeripheralViewControllerWillDismiss(_ remotePeripheralViewController: RemotePeripheralViewController) {
        do {
            try central.disconnectRemotePeripheral(remotePeripheralViewController.remotePeripheral)
        } catch let error {
            Logger.log("Error disconnecting remote peripheral: \(error)")
        }
    }

}
