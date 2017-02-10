//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 07/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()

    }
    
    
    @IBAction func scan(_ sender: Any) {

        BluetoothManager.shared.scan()

    }


}

