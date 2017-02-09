//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import CoreBluetooth

class Peripheral: CBPeripheral {

    var localName = "Peripheral - macOS"
    override var name: String? { return self.localName }

    override var identifier: UUID { return UUID(uuidString: "199ab74c-eed0-11e6-bc64-92361f002672")! }


}

class BluetoothManager: NSObject {

    // MARK: - Properties
    static let shared: BluetoothManager = BluetoothManager()
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let manager: CBPeripheralManager = CBPeripheralManager()
    let peripheral: Peripheral = Peripheral()

    // MARK: - Initializers
    override init () {

        super.init()

        self.peripheral.delegate = self
        self.manager.delegate = self

    }

    // MARK: - Functions
    func start() {

        guard let serviceUUID: UUID = UUID(uuidString: self.serviceUUID) else { return }
        self.manager.removeAllServices()
        self.manager.add(CBMutableService(type: CBUUID(nsuuid: serviceUUID), primary: false))
        self.manager.startAdvertising([:])

    }

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

    }


}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {

        print("didUpdateName: \(peripheral.name)")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        print("didDiscoverServices: \(peripheral.services)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {

        print("didReadRSSI RSSI: \(peripheral.name) \(RSSI)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        print("didModifyServices invalidatedServices: \(peripheral.name) \(invalidatedServices)")

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {

        print("didWriteValueFor descriptor: \(peripheral.name) \(descriptor)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {

        print("didUpdateValueFor descriptor: \(peripheral.name) \(descriptor)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("didDiscoverCharacteristicsFor service: \(peripheral.name) \(service)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {

        print("didDiscoverIncludedServicesFor service: \(peripheral.name) \(service)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        print("didWriteValueFor characteristic: \(peripheral.name) \(characteristic)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        print("didUpdateValueFor characteristic: \(peripheral.name) \(characteristic)")
        print("error: \(error)")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didDiscoverDescriptorsFor characteristic: \(peripheral.name) \(characteristic)")
        print("error: \(error)")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didUpdateNotificationStateFor characteristic: \(peripheral.name) \(characteristic)")
        print("error: \(error)")
        
    }
    
}
