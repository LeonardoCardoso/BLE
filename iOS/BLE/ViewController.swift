//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 07/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!

    // MARK: - Lifecyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - Properties
    var bluetoothManager: BluetoothManager?

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        self.bluetoothManager = BluetoothManager(delegate: self)

    }

}

// MARK: - BluetoothMessaging
extension ViewController: BluetoothMessaging {

    func didStartConfiguration() {

        self.label.text = "\(Date()) Start configuration"
        print(self.label.text ?? "")

    }

    func didSendData(data: [String: Any]?) {

        self.label.text = "\(Date()) Did send data"
        print("Did send data: ", data ?? [:])

    }

    func didFailToSendData() {

        self.label.text = "\(Date()) Did fail to send data"
        print(self.label.text ?? "")

    }

    func didReceiveData(data: [String: Any]?) {

        self.label.text = "\(Date()) Did received data"
        print("Did received data: ", data ?? [:])

    }

    func centralDidConnect(identifier: UUID?) {

        guard let identifier: UUID = identifier else { return }
        self.label.text = "\(Date()) Central connected: \(identifier)"
        print(self.label.text ?? "")

    }

    func centralDidDisconnect(identifier: UUID?) {

        guard let identifier: UUID = identifier else { return }
        self.label.text = "\(Date()) Central disconnected: \(identifier)"
        print(self.label.text ?? "")

    }

}

