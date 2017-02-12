//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import CoreBluetooth
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
    let peripheralId: String = "62443cc7-15bc-4136-bf5d-0ad80c459215"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11E6-BC64-92361F002672"
    let localName: String = "Peripheral - iOS"

    let peripheral: BKPeripheral = BKPeripheral()

    var bluetoothMessaging: BluetoothMessaging?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging?) {

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
            print("Waiting connections from remote centrals")

        } catch let error {

            // Handle error.
            print(error)

        }

    }

    // MARK: - Functions
    func sendData(_ remotePeer: BKRemotePeer) {

        let info: [String: String] = [
            "action": "open",
            "peripheralId": self.peripheralId,
            "peripheralName": self.localName
        ]

        let data: Data = NSKeyedArchiver.archivedData(withRootObject: info)

        self.peripheral.sendData(data, toRemotePeer: remotePeer) { data, remoteCentral, error in

            if error != nil {

                print(error.debugDescription)
                self.bluetoothMessaging?.didFailToSendData()

            } else {

                self.bluetoothMessaging?.didSendData(data: info)

            }

        }


    }

}

// MARK: - BKRemotePeerDelegate
extension BluetoothManager: BKRemotePeerDelegate {

    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {

        self.bluetoothMessaging?.didReceiveData(data: NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any])

        for remoteCentral in self.peripheral.connectedRemoteCentrals { self.sendData(remoteCentral) }

    }

}

// MARK: - BKPeripheralDelegate
extension BluetoothManager: BKPeripheralDelegate {

    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {

        remoteCentral.delegate = self
        self.bluetoothMessaging?.centralDidConnect(identifier: remoteCentral.identifier)
        self.sendData(remoteCentral)

    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        
        self.bluetoothMessaging?.centralDidDisconnect(identifier: remoteCentral.identifier)
        
    }
    
}
