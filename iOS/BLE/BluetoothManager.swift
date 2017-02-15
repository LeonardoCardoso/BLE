//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import CoreBluetooth

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

    var bluetoothMessaging: BluetoothMessaging?
    var peripheralManager: CBPeripheralManager?

    var service: CBMutableService?

    let properties: CBCharacteristicProperties = [.read, .notify, .writeWithoutResponse, .write]
    let permissions: CBAttributePermissions = [.readable, .writeable]

    var characterisctic: CBMutableCharacteristic?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging?) {

        self.init()

        self.bluetoothMessaging = delegate

        guard
            let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
            let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
            else { return }

        self.service = CBMutableService(type: CBUUID(nsuuid: serviceUUID), primary: true)

        self.characterisctic = CBMutableCharacteristic(type: CBUUID(nsuuid: characteristicUUID), properties: properties, value: nil, permissions: permissions)

        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: self.peripheralId])

        guard let characterisctic: CBCharacteristic = self.characterisctic else { return }

        self.service?.characteristics = [characterisctic]

    }

}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothManager: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        print("peripheralManagerDidUpdateState")

        if peripheral.state == .poweredOn {

            guard let service: CBMutableService = self.service else { return }

            peripheral.add(service)

        }

    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {

        print("peripheralManagerIsReady")

        let data: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [self.service?.uuid],
            CBAdvertisementDataLocalNameKey: "Peripheral - iOS"
        ]
        peripheral.startAdvertising(data)

    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {

        print("peripheralManagerDidStartAdvertising")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {

        print("didReceiveRead request")

        if let uuid: CBUUID = self.characterisctic?.uuid, request.characteristic.uuid == uuid {

            print("Match characteristic for reading")

            if let value: Data = self.characterisctic?.value, request.offset > value.count {

                print("Sending response: Error offset")

                self.peripheralManager?.respond(to: request, withResult: .invalidOffset)

            } else {

                print("Sending response: Success")
                self.peripheralManager?.respond(to: request, withResult: .success)

            }

        }


    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")


    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {

        print("didAdd service")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

        print("didReceiveWrite requests")

        guard let uuid: CBUUID = self.characterisctic?.uuid else { return }

        let characteristicCBUUID: CBUUID = uuid

        for request: CBATTRequest in requests {

            if request.characteristic.uuid == characteristicCBUUID {

                print("Match characteristic for writing")

                if
                    let value: Data = request.characteristic.value,
                    let receivedData: [String: String] = NSKeyedUnarchiver.unarchiveObject(with: value) as? [String: String] {

                    print("Written value is: \(receivedData)")

                }

            }

        }

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        print("didSubscribeTo characteristic")

        guard let characterisctic: CBMutableCharacteristic = self.characterisctic else { return }
        
        let dict: [String: String] = ["Hello": "Darkness"]
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
        self.peripheralManager?.updateValue(data, for: characterisctic, onSubscribedCentrals: [central])

    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("didUnsubscribeFrom characteristic")
        
        
    }
    
}
