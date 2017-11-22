//
//  ViewController.swift
//  BLE
//
//  Created by Leonardo Cardoso on 07/02/2017.
//  Copyright © 2017 leocardz.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet var label: UILabel!

    // MARK: - Lifecyle
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - Properties
    var manager: BluetoothManager?

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        self.manager = BluetoothManager(delegate: self)

    }

}

// MARK: - BlueEar
extension ViewController: BlueEar {

    func didStartConfiguration() { self.label.text = "Start configuration 🎛" }

    func didStartAdvertising() { self.label.text = "Start advertising 📻" }

    func didSendData() { self.label.text = "Did send data ⬆️" }

    func didReceiveData() { self.label.text = "Did received data ⬇️" }

}
