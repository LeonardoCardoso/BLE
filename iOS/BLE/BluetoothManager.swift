//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject {

    // MARK: - Properties
    static let shared: BluetoothManager = BluetoothManager()
    let restoreIdentifier: String = "054656d3-bfe4-4b5c-afe7-8cce05f52be7"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002671"
    let localName = "Central - iOS"
    var manager: CBCentralManager?

    // MARK: - Initializers
    override init () {

        super.init()

        self.manager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [CBCentralManagerOptionRestoreIdentifierKey: self.restoreIdentifier]
        )

    }

    // MARK: - Functions
    func scan() { }

}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("didConnect peripheral: \(peripheral.name)")


    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("didDisconnectPeripheral peripheral: \(peripheral.name)")

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("didDiscover peripheral: \(peripheral.name)")
        print("advertisementData: \(advertisementData)")

        peripheral.delegate = self
        self.manager?.connect(peripheral, options: [:])

    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        print("didFailToConnect peripheral: \(peripheral.name)")
        print("error: \(error)")


    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")
        print("dict: \(dict)")

    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print("didUpdateState")

        guard let serviceUUID: UUID = UUID(uuidString: serviceUUID) else { return }

        if central.state == .poweredOn {

            central.scanForPeripherals(withServices: [CBUUID(nsuuid: serviceUUID)], options: [:])

        }

    }


}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {

        print("didUpdateName: \(peripheral.name)")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        print("didDiscoverServices: \(peripheral.name)")
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
