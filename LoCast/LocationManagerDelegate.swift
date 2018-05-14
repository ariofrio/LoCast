//
//  LocationDelegate.swift
//  LoCast
//
//  Created by user140378 on 5/12/18.
//  Copyright © 2018 Andres Riofrio. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let updateLocationHandler: (CLLocation) -> ()
    
    init(updateLocationHandler: @escaping (CLLocation) -> ()) {
        self.updateLocationHandler = updateLocationHandler
        super.init()
    }
    
    func requestStartUpdatingLocation(viewControllerToPresent: UIViewController, inBackground: Bool) -> Guarantee<Bool> {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .denied {
            let alert = UIAlertController(
                    title: "Allow \"LoCast\" to access your location?",
                    message: (Bundle.main.object(
                        forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as! String),
                    preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Don't Allow", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Go To Settings", style: .default, handler: { _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            viewControllerToPresent.present(alert, animated: true, completion: nil)
            return Guarantee.value(false)
        } else if !isAuthorized(inBackground: inBackground, status: authorizationStatus) {
            return firstly {
                CLLocationManager.requestAuthorization(type: inBackground ? .always : .whenInUse)
            }.then { newAuthorizationStatus in
                print(newAuthorizationStatus)
                if self.isAuthorized(inBackground: inBackground, status: newAuthorizationStatus) {
                    self.startUpdatingLocation()
                    return Guarantee.value(true)
                } else {
                    return Guarantee.value(false)
                }
            }
        } else if !CLLocationManager.locationServicesEnabled() {
            return Guarantee.value(false)
        } else {
            startUpdatingLocation()
            return Guarantee.value(true)
        }
    }
    
    private func isAuthorized(inBackground: Bool, status: CLAuthorizationStatus) -> Bool {
        if status == .authorizedAlways {
            return true
        } else if status == .authorizedWhenInUse {
            return !inBackground
        }
        return false
    }
    
    public func resumeUpdatingLocationFromBackground() {
        startUpdatingLocation()
    }
    
    private func startUpdatingLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0 // In meters
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            self.updateLocationHandler(lastLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // This method is called when the user denies authorization for your app to use location services, among other errors
        
        if let error = error as? CLError, error.code == .denied {
            // The user denied authorization for the app to use location services.
            manager.stopUpdatingLocation()
            return
        }
        fatalError("Unresolved error \(error), \(error.localizedDescription)")
    }
    
}
