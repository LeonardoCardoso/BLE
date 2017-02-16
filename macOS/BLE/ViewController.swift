//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import Cocoa

class ViewController: NSViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var button: NSButton!

    // MARK: - Properties
    var manager: BluetoothManager?

    // MARK: - Lifecyle
    @IBAction func discover(_ sender: Any) {

        self.manager = BluetoothManager(delegate: self)
        self.manager?.scan()

    }

}

// MARK: - BlueEar
extension ViewController: BlueEar {

    func didStartConfiguration() { self.label.stringValue = "Start configuration 🎛" }

    func didStartScanningPeripherals() { self.label.stringValue = "Start scanning peripherals 👀" }

    func didConnectPeripheral(name: String?) { self.label.stringValue = "Did connect to: \(name ?? "") 🤜🏽🤛🏽" }

    func didDisconnectPeripheral(name: String?) { self.label.stringValue = "Did disconnect: \(name ?? "") 🤜🏽🤚🏽" }

    func didSendData() { self.label.stringValue = "Did send data ⬆️" }

    func didReceiveData() { self.label.stringValue = "Did received data ⬇️" }

    func didFailConnection() { self.label.stringValue = "Connection failed 🤷🏽‍♂️" }
    
}

