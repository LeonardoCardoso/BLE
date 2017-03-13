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

protocol BlueEar {

    func didStartConfiguration()

    func didStartScanningPeripherals()

    func didConnectPeripheral(name: String?)
    func didDisconnectPeripheral(name: String?)

    func didSendData()
    func didReceiveData()

    func didFailConnection()

}

class BluetoothManager: NSObject {

    // MARK: - Properties
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"

    var serviceCBUUID: CBUUID?
    var characteristicCBUUID: CBUUID?

    var blueEar: BlueEar?

    var centralManager: CBCentralManager?

    var discoveredPeripheral: CBPeripheral?

    // MARK: - Initializers
    convenience init (delegate: BlueEar) {

        self.init()

        self.blueEar = delegate

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
        self.blueEar?.didStartConfiguration()

    }

}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print("\ncentralManagerDidUpdateState \(Date())")

        if central.state == .poweredOn {

            guard let serviceCBUUID: CBUUID = self.serviceCBUUID else { return }

            self.blueEar?.didStartScanningPeripherals()
            self.centralManager?.scanForPeripherals(withServices: [serviceCBUUID], options: nil)

        }

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // We must keep a reference to the new discovered peripheral, which means we must retain it.
        self.discoveredPeripheral = peripheral

        print("\ndidDiscover:", self.discoveredPeripheral?.name ?? "")

        self.discoveredPeripheral?.delegate = self

        guard let discoveredPeripheral: CBPeripheral = self.discoveredPeripheral else { return }
        self.centralManager?.connect(discoveredPeripheral, options: nil)
        
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("\ndidConnect", self.discoveredPeripheral?.name ?? "")

        self.blueEar?.didConnectPeripheral(name: peripheral.name ?? "")

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

        self.blueEar?.didFailConnection()

    }

    func centralManager(_ central: CBCentralManager, didRetrieveConnectedPeripherals peripherals: [CBPeripheral]) {

        print("\ndidRetrieveConnectedPeripherals")


    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("\ndidDisconnectPeripheral", self.discoveredPeripheral?.name ?? "")
        self.blueEar?.didDisconnectPeripheral(name: peripheral.name ?? "")

    }

}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        print("\ndidDiscoverServices")

        if let service: CBService = self.discoveredPeripheral?.services?.filter({ $0.uuid == self.serviceCBUUID }).first {

            guard let characteristicCBUUID: CBUUID = self.characteristicCBUUID else { return }

            self.discoveredPeripheral?.discoverCharacteristics([characteristicCBUUID], for: service)

        }
        
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        print("\ndidWriteValueFor \(Date())")

        // After we write data on peripheral, we disconnect it.
        self.centralManager?.cancelPeripheralConnection(peripheral)

        // We stop scanning.
        self.centralManager?.stopScan()

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("\ndidDiscoverCharacteristicsFor")

        if let characteristic: CBCharacteristic = service.characteristics?.filter({ $0.uuid == self.characteristicCBUUID }).first {

            print("Matching characteristic")

            // To listen and read dynamic values
            self.discoveredPeripheral?.setNotifyValue(true, for: characteristic)

            // To read static values
            // self.discoveredPeripheral?.readValue(for: characteristic)
            
        }
        
        
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        print("\ndidUpdateValueFor")

        // We read
        if let value: Data = characteristic.value {

            do {

                let receivedData: [String: String] = try PropertyListSerialization.propertyList(from: value, options: [], format: nil) as! [String: String]

                print("Value read is: \(receivedData)")
                self.blueEar?.didReceiveData()

            } catch let error {

                print(error)

            }

        }

        // We write
        do {

            print("\nWriting on peripheral.")

            let dict: [String: String] = ["Yo": "Lo"]
            let data: Data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)

            self.discoveredPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
            self.blueEar?.didSendData()
            
        } catch let error {
            
            print(error)
            
        }
        
    }

    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {

        print("\nperipheralDidUpdateRSSI")
        print(self.discoveredPeripheral?.rssi ?? "")
        
    }

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {

        print("\nperipheralDidUpdateName")

    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {

        print("\ndidWriteValueFor")

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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidDiscoverDescriptorsFor")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidUpdateNotificationStateFor")
        
    }
    
}
