//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject {

    // MARK: - Properties
    static let shared: BluetoothManager = BluetoothManager()
    let restoreIdentifier: String = "62443cc7-15bc-4136-bf5d-0ad80c459215"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"
    let localName = "Peripheral - macOS"
    var manager: CBPeripheralManager?

    // MARK: - Initializers
    override init () {

        super.init()

        self.manager = CBPeripheralManager(delegate: self, queue: nil)

    }

    // MARK: - Functions
    func discover() { }

}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothManager: CBPeripheralManagerDelegate {

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {

        print("didReceiveRead request: \(request.central.identifier)")

    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {

        print("didStartAdvertising")
        print("error: \(error)")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")
        print("dict: \(dict)")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {

        print("didSubscribeTo characteristic: \(characteristic.value)")
        print("central: \(central.identifier)")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {

        print("didUnsubscribeFrom characteristic: \(characteristic.value)")
        print("central: \(central.identifier)")

    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

        print("didReceiveWrite requests: \(requests)")


    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {

        print("didAdd service: \(service.characteristics)")
        print("error: \(error)")

    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {

        print("managerIsReady")

    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        print("didUpdateState")

        if peripheral.state == .poweredOn {

//            guard let serviceUUID: UUID = UUID(uuidString: self.serviceUUID) else { return }
//            peripheral.discoverServices([CBUUID(nsuuid: serviceUUID)])
            peripheral.startAdvertising(["Hallo": "Wie geht's"])
        
        }

    }
    
    
}
