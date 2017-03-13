//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import CoreBluetooth

protocol BlueEar {

    func didStartConfiguration()

    func didStartAdvertising()

    func didSendData()
    func didReceiveData()

}

class BluetoothManager: NSObject {

    // MARK: - Properties
    let peripheralId: String = "62443cc7-15bc-4136-bf5d-0ad80c459215"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11E6-BC64-92361F002672"
    let localName: String = "Peripheral - iOS"

    let properties: CBCharacteristicProperties = [.read, .notify, .writeWithoutResponse, .write]
    let permissions: CBAttributePermissions = [.readable, .writeable]

    var bluetoothMessaging: BlueEar?
    var peripheralManager: CBPeripheralManager?

    var serviceCBUUID: CBUUID?
    var characteristicCBUUID: CBUUID?

    var service: CBMutableService?

    var characterisctic: CBMutableCharacteristic?

    // MARK: - Initializers
    convenience init (delegate: BlueEar?) {

        self.init()

        self.bluetoothMessaging = delegate

        guard
            let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
            let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
            else { return }

        self.serviceCBUUID = CBUUID(nsuuid: serviceUUID)
        self.characteristicCBUUID = CBUUID(nsuuid: characteristicUUID)

        guard
            let serviceCBUUID: CBUUID = self.serviceCBUUID,
            let characteristicCBUUID: CBUUID = self.characteristicCBUUID
            else { return }

        // Configuring service
        self.service = CBMutableService(type: serviceCBUUID, primary: true)

        // Configuring characteristic
        self.characterisctic = CBMutableCharacteristic(type: characteristicCBUUID, properties: self.properties, value: nil, permissions: self.permissions)

        guard let characterisctic: CBCharacteristic = self.characterisctic else { return }

        // Add characterisct to service
        self.service?.characteristics = [characterisctic]

        self.bluetoothMessaging?.didStartConfiguration()

        // Initiate peripheral and start advertising
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)

    }

}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothManager: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        print("peripheralManagerDidUpdateState")

        if peripheral.state == .poweredOn {

            guard let service: CBMutableService = self.service else { return }

            self.peripheralManager?.removeAllServices()
            self.peripheralManager?.add(service)

        }

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {

        print("\ndidAdd service")

        let advertisingData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [self.service?.uuid],
            CBAdvertisementDataLocalNameKey: "Peripheral - iOS"
        ]
        self.peripheralManager?.stopAdvertising()
        self.peripheralManager?.startAdvertising(advertisingData)

    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {

        print("peripheralManagerDidStartAdvertising")
        self.bluetoothMessaging?.didStartAdvertising()

    }

    // Listen to dynamic values
    // Called when CBPeripheral .setNotifyValue(true, for: characteristic) is called from the central
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {

        print("\ndidSubscribeTo characteristic")

        guard let characterisctic: CBMutableCharacteristic = self.characterisctic else { return }

        do {

            // Writing data to characteristics
            let dict: [String: String] = ["Hello": "Darkness"]
            let data: Data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)

            self.peripheralManager?.updateValue(data, for: characterisctic, onSubscribedCentrals: [central])
            self.bluetoothMessaging?.didSendData()

        } catch let error {

            print(error)

        }

    }

    // Read static values
    // Called when CBPeripheral .readValue(for: characteristic) is called from the central
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {

        print("\ndidReceiveRead request")

        if let uuid: CBUUID = self.characterisctic?.uuid, request.characteristic.uuid == uuid {

            print("Match characteristic for static reading")

        }

    }

    // Called when receiving writing from Central.
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

        print("\ndidReceiveWrite requests")

        guard
            let characteristicCBUUID: CBUUID = self.characteristicCBUUID,
            let request: CBATTRequest = requests.filter({ $0.characteristic.uuid == characteristicCBUUID }).first,
            let value: Data = request.value
            else { return }

        // Send response to central if this writing request asks for response [.withResponse]
        print("Sending response: Success")
        self.peripheralManager?.respond(to: request, withResult: .success)

        print("Match characteristic for writing")

        do {

            if let receivedData: [String : String] = try PropertyListSerialization.propertyList(from: value, options: [], format: nil) as? [String: String] {

                print("Written value is: \(receivedData)")
                self.bluetoothMessaging?.didReceiveData()

            } else {

                return

            }

        } catch let error {

            print(error)

        }

    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("\ndidUnsubscribeFrom characteristic")
        
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        
        print("willRestoreState")
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        print("peripheralManagerIsReady")
        
    }
    
}
