//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 09/02/2017.
//  Copyright © 2017 1aim.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import Cocoa

class ViewController: NSViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var button: NSButton!

    // MARK: - Lifecyle
    override func viewDidLoad() {

        super.viewDidLoad()

    }
    
    
    @IBAction func discover(_ sender: Any) {

        BluetoothManager.shared.discover()

    }

}

