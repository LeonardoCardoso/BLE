//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import BluetoothKit

class BluetoothManager: NSObject {

    // MARK: - Properties
    static let shared: BluetoothManager = BluetoothManager()

    let restoreIdentifier: String = "62443cc7-15bc-4136-bf5d-0ad80c459215"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"
    let localName = "Peripheral - macOS"

    let peripheral = BKPeripheral()

    // MARK: - Initializers
    override init () {

        super.init()

        self.peripheral.delegate = self

        do {

            guard
                let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
                let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
                else { return }

            let configuration = BKPeripheralConfiguration(
                dataServiceUUID: serviceUUID,
                dataServiceCharacteristicUUID: characteristicUUID,
                localName: self.localName
            )

            try self.peripheral.startWithConfiguration(configuration)
            print("startWithConfiguration")
            // You are now ready for incoming connections

        } catch let error {

            // Handle error.
            print(error)
            
        }

    }

    // MARK: - Functions
    func discover() {

    }

}

//// MARK: - CBPeripheralManagerDelegate
extension BluetoothManager: BKPeripheralDelegate {

    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {

        print("remoteCentralDidConnect remoteCentral:")

    }

    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {

        print("remoteCentralDidDisconnect remoteCentral:")

    }

}
