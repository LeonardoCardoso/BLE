//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import Cocoa

class ViewController: NSViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var button: NSButton!

    // MARK: - Properties
    var bluetoothManager: BluetoothManager?

    // MARK: - Lifecyle
    @IBAction func discover(_ sender: Any) {

        self.bluetoothManager = BluetoothManager(delegate: self)
        self.bluetoothManager?.scan()

    }

}

// MARK: - BluetoothMessaging
extension ViewController: BluetoothMessaging {


    func didStartConfiguration() {

        self.label.stringValue = "\(Date()) Start configuration"
        print(self.label.stringValue)

    }

    func didStartScanningPeripherals() {

        self.label.stringValue = "\(Date()) Start scanning peripherals"
        print(self.label.stringValue)
        
        
    }

    func didConnectPeripheral(name: String?) {

        guard let name: String = name else { return }
        self.label.stringValue = "\(Date()) Did connect to: \(name)"
        print(self.label.stringValue)

    }


    func didDisconnectPeripheral(name: String?) {

        guard let name: String = name else { return }
        self.label.stringValue = "\(Date()) Did disconnect: \(name)"
        print(self.label.stringValue)

    }


    func didSendData(data: [String: Any]?) {

        self.label.stringValue = "\(Date()) Did send data"
        print("Did send data: ", data ?? [:])

    }

    func didReceiveData(data: [String: Any]?) {

        self.label.stringValue = "\(Date()) Did received data"
        print("Did received data: ", data ?? [:])

    }

    func didFailConnection() {

        self.label.stringValue = "\(Date()) Connection failed"
        print(self.label.stringValue)

    }

    
}

