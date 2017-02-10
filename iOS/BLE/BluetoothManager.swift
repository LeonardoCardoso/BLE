//
//  BluetoothManager.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import Foundation
import BluetoothKit

class BluetoothManager: NSObject {

    // MARK: - Properties
    static let shared: BluetoothManager = BluetoothManager()

    let restoreIdentifier: String = "054656d3-bfe4-4b5c-afe7-8cce05f52be7"
    let serviceUUID: String = "0cdbe648-eed0-11e6-bc64-92361f002671"
    let characteristicUUID: String = "199ab74c-eed0-11e6-bc64-92361f002672"

    let central = BKCentral()

    // MARK: - Initializers
    override init () {

        super.init()

        self.central.delegate = self
        self.central.addAvailabilityObserver(self)

        do {

            guard
                let serviceUUID: UUID = NSUUID(uuidString: self.serviceUUID) as UUID?,
                let characteristicUUID: UUID = NSUUID(uuidString: self.characteristicUUID) as UUID?
                else { return }

            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)

            try self.central.startWithConfiguration(configuration)
            print("startWithConfiguration")
            // Once the availability observer has been positively notified, you're ready to discover and connect to peripherals.

        } catch let error {

            // Handle error.
            print(error)
            
        }

    }

    // MARK: - Functions
    func scan() {


    }

}

extension BluetoothManager: BKCentralDelegate {

    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {

        print("remotePeripheralDidDisconnect remotePeripheral: \(remotePeripheral.name)")

    }

}

extension BluetoothManager: BKAvailabilityObserver {


    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {

        print("availabilityDidChange availability: \(availability)")
        if availability == .available {

            self.central.scanWithDuration(3, progressHandler: { newDiscoveries in

                // Handle newDiscoveries, [BKDiscovery].
                print(newDiscoveries)


            }, completionHandler: { result, error in
                // Handle error.
                // If no error, handle result, [BKDiscovery].

                print(result?.count, error)

                if error == nil, let result: [BKDiscovery] = result, result.count > 0 {

                    self.central.connect(remotePeripheral: result[0].remotePeripheral) { remotePeripheral, error in

                        // Handle error.
                        // If no error, you're ready to receive data!
                        print("\(remotePeripheral.name)")
                        print("error: \(error)")

                    }

                }

            })
            
        }
        
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        
        print("unavailabilityCauseDidChange unavailabilityCause: \(unavailabilityCause)")
        
    }
    
}
