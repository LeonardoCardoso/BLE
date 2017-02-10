//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import BluetoothKit

protocol BluetoothMessaging {

    func didStartConfiguration()

    func didSendData(data: [String: Any]?)
    func didFailToSendData()
    func didReceiveData(data: [String: Any]?)

    func centralDidConnect(identifier: UUID?)
    func centralDidDisconnect(identifier: UUID?)

}

class BluetoothManager: NSObject {

    // MARK: - Properties
    let restoreIdentifier: String = "62443cc7-15bc-4136-bf5d-0ad80c459215"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"
    let localName = "Peripheral - iOS"

    let peripheral = BKPeripheral()

    var bluetoothMessaging: BluetoothMessaging?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging) {

        self.init()

        self.bluetoothMessaging = delegate
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
            self.bluetoothMessaging?.didStartConfiguration()

            // You are now ready for incoming connections

        } catch let error {

            // Handle error.
            print(error)

        }

    }

    // MARK: - Functions
    func sendData(_ remoteCentral: BKRemoteCentral) {

        let info: [String: String] = [
            "action": "open",
            "peripheralId": self.restoreIdentifier
        ]

        let data: Data = NSKeyedArchiver.archivedData(withRootObject: info)

        self.peripheral.sendData(data, toRemotePeer: remoteCentral) { data, remoteCentral, error in

            if error != nil {

                print(error.debugDescription)
                self.bluetoothMessaging?.didFailToSendData()

            } else {

                self.bluetoothMessaging?.didSendData(data: info)
                
            }
            
        }
        
        
    }

}

// MARK: - BKPeripheralDelegate
extension BluetoothManager: BKPeripheralDelegate {

    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {

        self.bluetoothMessaging?.centralDidConnect(identifier: remoteCentral.identifier)

    }

    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {

        self.bluetoothMessaging?.centralDidDisconnect(identifier: remoteCentral.identifier)

    }
    
}
