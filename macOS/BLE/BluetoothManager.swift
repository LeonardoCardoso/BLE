//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import Cocoa

protocol BluetoothMessaging {

    func didStartConfiguration()

    func didConnectPeripheral(name: String?)
    func didDisconnectPeripheral(name: String?)

    func didSendData(data: [String: Any]?)
    func didFailToSendData()
    func didReceiveData(data: [String: Any]?)

    func didConnectionFailed()

    func peripheralDidDisconnect(name: String?)

}

class BluetoothManager: NSObject {

    // MARK: - Properties
    let centralId: String = "62443cc7-15bc-4136-bf5d-0ad80c459216"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"

    var bluetoothMessaging: BluetoothMessaging?

    var centralManager: CBCentralManager?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging) {

        self.init()

        self.bluetoothMessaging = delegate

    }

    // MARK: - Functions
    func scan() {

        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)

    }

}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print("centralManagerDidUpdateState")

        if central.state == .poweredOn {

            guard let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID? else { return }

            self.centralManager?.scanForPeripherals(withServices: [CBUUID(nsuuid: serviceUUID)], options: nil)

        }

    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("didConnect")

        guard let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID? else { return }

        peripheral.discoverServices([CBUUID(nsuuid: serviceUUID)])


    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")


    }

    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {

        print("didRetrievePeripherals")


    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        print("didFailToConnect")


    }

    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {

        print("didRetrieveConnectedPeripherals")


    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("didDisconnectPeripheral")

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("didDiscover: \(peripheral.name)")

        peripheral.delegate = self

        self.centralManager?.stopScan()
        self.centralManager?.connect(peripheral, options: nil)

    }

}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {


    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {

        print("peripheralDidUpdateName")

    }

    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {

        print("peripheralDidUpdateRSSI")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        print("didDiscoverServices")

        guard
            let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
            let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?,
            let services: [CBService] = peripheral.services
            else { return }

        let serviceCBUUID: CBUUID = CBUUID(nsuuid: serviceUUID)

        for service: CBService in services {

            if service.uuid == serviceCBUUID {

                peripheral.discoverCharacteristics([CBUUID(nsuuid: characteristicUUID)], for: service)

            }

        }

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {

        print("didWriteValueFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("didDiscoverCharacteristicsFor")

        guard
            let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?,
            let characteristics: [CBCharacteristic] = service.characteristics
            else { return }

        let characteristicCBUUID: CBUUID = CBUUID(nsuuid: characteristicUUID)

        for characteristic: CBCharacteristic in characteristics {

            if characteristic.uuid == characteristicCBUUID {

                print("Reading Data")

                // For static values
                peripheral.readValue(for: characteristic)

                // For dynamic values
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            
        }


    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        print("didModifyServices")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {

        print("didUpdateValueFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {

        print("didDiscoverIncludedServicesFor")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didWriteValueFor")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didUpdateValueFor")

        print("Data: \(characteristic.value)")

        print("Write on peripheral.")
        let dict: [String: String] = ["Yo": "Lo"]
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didDiscoverDescriptorsFor")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didUpdateNotificationStateFor")
        
    }
    
}
