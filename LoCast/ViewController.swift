//
//  ViewController.swift
//  LoCast
//
//  Created by user140378 on 5/12/18.
//  Copyright © 2018 Andres Riofrio. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {

    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func changeBroadcastStatus(_ sender: Any) {
        if broadcastSwitch.isOn {
            firstly {
                LocationManagerDelegate.shared.requestStartUpdatingLocation(
                    viewControllerToPresent: self, inBackground: false)
            }.done { success in
                if !success {
                    self.broadcastSwitch.isOn = false
                }
            }
        } else {
            // TODO
        }
    }

}

