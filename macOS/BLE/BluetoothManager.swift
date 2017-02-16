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

    func didStartScanningPeripherals()

    func didConnectPeripheral(name: String?)
    func didDisconnectPeripheral(name: String?)

    func didSendData(data: [String: Any]?)
    func didReceiveData(data: [String: Any]?)

    func didFailConnection()

}

class BluetoothManager: NSObject {

    // MARK: - Properties
    let centralId: String = "62443cc7-15bc-4136-bf5d-0ad80c459216"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"
    let peripheralLocalName: String = "Peripheral - iOS"

    var serviceCBUUID: CBUUID?
    var characteristicCBUUID: CBUUID?

    var bluetoothMessaging: BluetoothMessaging?

    var centralManager: CBCentralManager?

    var discoveredPeripheral: CBPeripheral?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging) {

        self.init()

        self.bluetoothMessaging = delegate

        guard
            let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
            let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
            else { return }

        self.serviceCBUUID = CBUUID(nsuuid: serviceUUID)
        self.characteristicCBUUID = CBUUID(nsuuid: characteristicUUID)

    }

    // MARK: - Functions
    func scan() {

        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        self.bluetoothMessaging?.didStartConfiguration()

    }

}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print("centralManagerDidUpdateState")

        if central.state == .poweredOn {

            guard let serviceCBUUID: CBUUID = self.serviceCBUUID else { return }

            self.bluetoothMessaging?.didStartScanningPeripherals()
            self.centralManager?.scanForPeripherals(withServices: [serviceCBUUID], options: nil)

        }

    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("\ndidConnect")

        self.bluetoothMessaging?.didConnectPeripheral(name: peripheral.name ?? "")

        guard let serviceCBUUID: CBUUID = self.serviceCBUUID else { return }

        self.discoveredPeripheral?.discoverServices([serviceCBUUID])


    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")


    }

    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripherals: [CBPeripheral]) {

        print("\ndidRetrievePeripherals")


    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        print("\ndidFailToConnect")

        self.bluetoothMessaging?.didFailConnection()


    }

    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {

        print("\ndidRetrieveConnectedPeripherals")


    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("\ndidDisconnectPeripheral")
        self.bluetoothMessaging?.didDisconnectPeripheral(name: peripheral.name ?? "")

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        guard let name: String = peripheral.name else { return }

        if name == self.peripheralLocalName {

            // We must keep a reference to the new discovered peripheral, which means we must retain it. http://stackoverflow.com/a/20711503/1255990
            self.discoveredPeripheral = peripheral

            print("\ndidDiscover:", self.discoveredPeripheral?.name ?? "")

            self.discoveredPeripheral?.delegate = self

            guard let discoveredPeripheral: CBPeripheral = self.discoveredPeripheral else { return }
            self.centralManager?.connect(discoveredPeripheral, options: nil)

        }

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

        print("\ndidDiscoverServices")

        guard
            let characteristicCBUUID: CBUUID = self.characteristicCBUUID,
            let services: [CBService] = self.discoveredPeripheral?.services
            else { return }

        for service: CBService in services {

            if service.uuid == self.serviceCBUUID {

                self.discoveredPeripheral?.discoverCharacteristics([characteristicCBUUID], for: service)

            }

        }

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {

        print("\ndidWriteValueFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("\ndidDiscoverCharacteristicsFor")

        guard let characteristics: [CBCharacteristic] = service.characteristics else { return }

        for characteristic: CBCharacteristic in characteristics {

            if characteristic.uuid == self.characteristicCBUUID {

                print("Reading Data")

                // For static values
                self.discoveredPeripheral?.readValue(for: characteristic)

                // For dynamic values
                self.discoveredPeripheral?.setNotifyValue(true, for: characteristic)

            }

        }


    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        print("\ndidModifyServices")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {

        print("\ndidUpdateValueFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {

        print("\ndidDiscoverIncludedServicesFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        print("\ndidWriteValueFor")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidUpdateValueFor")

        if
            let value: Data = characteristic.value,
            let receivedData: [String: String] = NSKeyedUnarchiver.unarchiveObject(with: value) as? [String: String] {

            print("Value read is: \(receivedData)")
            self.bluetoothMessaging?.didReceiveData(data: receivedData)

        }

        print("Write on peripheral.")
        let dict: [String: String] = ["Yo": "Lo"]
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
        self.discoveredPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        self.bluetoothMessaging?.didSendData(data: dict)

        // After we write data on peripheral, we can disconnect it like this
        guard let discoveredPeripheral: CBPeripheral = self.discoveredPeripheral else { return }
        self.centralManager?.cancelPeripheralConnection(discoveredPeripheral)

        // We stop scanning.
        self.centralManager?.stopScan()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidDiscoverDescriptorsFor")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidUpdateNotificationStateFor")
        
    }
    
}
