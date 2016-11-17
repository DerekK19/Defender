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
import SnapKit

internal class RoleSelectionViewController: UIViewController {

    // MARK: Properties

    private let offset = CGFloat(20)
    private let buttonColor = Colors.darkBlue
    private let centralButton = UIButton(type: UIButtonType.custom)
    private let peripheralButton = UIButton(type: UIButtonType.custom)

    // MARK: UIViewController Life Cycle

    internal override func viewDidLoad() {
        navigationItem.title = "Select Role"
        view.backgroundColor = UIColor.white
        centralButton.setTitle("Central", for: UIControlState())
        peripheralButton.setTitle("Peripheral", for: UIControlState())
        preparedButtons([ centralButton, peripheralButton ], andAddThemToView: view)
        applyConstraints()
        #if os(tvOS)
            peripheralButton.enabled = false
        #endif
    }

    // MARK: Functions

    private func preparedButtons(_ buttons: [UIButton], andAddThemToView view: UIView) {
        for button in buttons {
            button.setBackgroundImage(UIImage.imageWithColor(buttonColor), for: UIControlState())
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            #if os(iOS)
                button.addTarget(self, action: #selector(RoleSelectionViewController.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
            #elseif os(tvOS)
                button.addTarget(self, action: #selector(RoleSelectionViewController.buttonTapped(_:)), forControlEvents: UIControlEvents.PrimaryActionTriggered)
            #endif

            view.addSubview(button)
        }
    }

    private func applyConstraints() {
        centralButton.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(offset)
            make.leading.equalTo(view).offset(offset)
            make.trailing.equalTo(view).offset(-offset)
            make.height.equalTo(peripheralButton)
        }
        peripheralButton.snp.makeConstraints { make in
            make.top.equalTo(centralButton.snp.bottom).offset(offset)
            make.leading.trailing.equalTo(centralButton)
            make.bottom.equalTo(view).offset(-offset)
        }
    }

    // MARK: Target Actions

    @objc private func buttonTapped(_ button: UIButton) {
        if button == centralButton {
            navigationController?.pushViewController(CentralViewController(), animated: true)
        } else if button == peripheralButton {
            #if os(iOS)
                navigationController?.pushViewController(PeripheralViewController(), animated: true)
            #endif
        }
    }

}
