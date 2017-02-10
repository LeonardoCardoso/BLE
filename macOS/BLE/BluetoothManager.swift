//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import BluetoothKit
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
    let restoreIdentifier: String = "054656d3-bfe4-4b5c-afe7-8cce05f52be7"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"

    let central = BKCentral()

    var bluetoothMessaging: BluetoothMessaging?

    // MARK: - Initializers
    convenience init (delegate: BluetoothMessaging) {

        self.init()

        self.bluetoothMessaging = delegate

        self.central.delegate = self

    }

    // MARK: - Functions
    func scan() {

        self.central.addAvailabilityObserver(self)

        do {

            guard
                let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
                let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
                else { return }

            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)

            try self.central.startWithConfiguration(configuration)
            self.bluetoothMessaging?.didStartConfiguration()

            // Once the availability observer has been positively notified, you're ready to discover and connect to peripherals.

        } catch let error {

            // Handle error.
            print(error)

        }

    }

    func sendData(_ remotePeripheral: BKRemotePeripheral) {

        let info: [String: String] = [
            "centralId": self.restoreIdentifier
        ]

        let data: Data = NSKeyedArchiver.archivedData(withRootObject: info)

        self.central.sendData(data, toRemotePeer: remotePeripheral) { data, remoteCentral, error in

            if error != nil {

                print(error.debugDescription)
                self.bluetoothMessaging?.didFailToSendData()

            } else {

                self.bluetoothMessaging?.didSendData(data: info)
                
            }
            
        }


    }

}

// MARK: - BKCentralDelegate
extension BluetoothManager: BKCentralDelegate {

    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {

        self.bluetoothMessaging?.peripheralDidDisconnect(name: remotePeripheral.name)

    }

}

// MARK: - BKAvailabilityObserver
extension BluetoothManager: BKAvailabilityObserver {


    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {

        print("Availability: \(availability)")
        if availability == .available {

            self.central
                .scanWithDuration(
                    3,
                    progressHandler: { newDiscoveries in print(newDiscoveries.count) }, completionHandler: { result, error in

                        if error == nil, let result: [BKDiscovery] = result, result.count > 0 {

                            for result: BKDiscovery in result {

                                self.central.connect(10.0, remotePeripheral: result.remotePeripheral) { remotePeripheral, error in

                                    if error == nil {

                                        print("Handshake: you're ready to receive data")
                                        self.bluetoothMessaging?.didConnectPeripheral(name: remotePeripheral.name)

                                        self.sendData(remotePeripheral)

                                    } else {

                                        print("error: \(error)")
                                        
                                    }
                                    
                                }



                            }

                        } else if error != nil {

                            print("\(error)")
                            self.bluetoothMessaging?.didConnectionFailed()

                        }
                        
                })
            
        }
        
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        
        print("unavailabilityCauseDidChange unavailabilityCause: \(unavailabilityCause)")
        
    }
    
}
