//
//  ViewController.swift
//  LoCast
//
//  Created by user140378 on 5/12/18.
//  Copyright © 2018 Andres Riofrio. All rights reserved.
//

import UIKit
import PromiseKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    var locationManager: LocationManagerDelegate?
    func inject(locationManager: LocationManagerDelegate) {
        self.locationManager = locationManager
    }
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var locationMap: MKMapView!
    
    override func viewDidLoad() {
        locationMap.delegate = self
    }
    
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
            // TODO: turn it off
        }
    }
	
    var userCoordinateAnnotations: [String: UserCoordinateAnnotation] = [:]
    func updateUserCoordinates(_ userCoordinates: [String: CLLocationCoordinate2D]) {
        for (userId, coordinate) in userCoordinates {
            if (userCoordinateAnnotations[userId] == nil) {
                // Add annotations for new users
                let annotation = UserCoordinateAnnotation(userId: userId, coordinate: coordinate)
                userCoordinateAnnotations[userId] = annotation
                locationMap.addAnnotation(annotation)
            } else {
                // Update users that are already being tracked
                userCoordinateAnnotations[userId]?.coordinate = coordinate
            }
        }
        
        let oldKeys = Set(userCoordinateAnnotations.keys)
        let newKeys = Set(userCoordinates.keys)
        let removedKeys = oldKeys.subtracting(newKeys)
        for userId in removedKeys {
            // Remove users that are not being tracked anymore
            locationMap.removeAnnotation(userCoordinateAnnotations[userId]!)
            userCoordinateAnnotations[userId] = nil
        }
    }
    
}

class UserCoordinateAnnotation: NSObject, MKAnnotation {
    let userId: String
    var coordinate: CLLocationCoordinate2D
    init(userId: String, coordinate: CLLocationCoordinate2D) {
        self.userId = userId
        self.coordinate = coordinate
    }
}

