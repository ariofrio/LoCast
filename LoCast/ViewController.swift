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
    var locationManager: LocationManagerDelegate?
    func inject(locationManager: LocationManagerDelegate) {
        self.locationManager = locationManager
    }
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    @IBAction func changeBroadcastStatus(_ sender: Any) {
        if broadcastSwitch.isOn {
            firstly {
                self.locationManager!.requestStartUpdatingLocation(
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

