//
//  Database.swift
//  LoCast
//
//  Created by user140378 on 5/13/18.
//  Copyright © 2018 Andres Riofrio. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class Persistence {
    var ref: DatabaseReference!
    var user: User
    
    init(user: User) {
        self.ref = Database.database().reference()
        self.user = user
    }
    
    func updateUserCoordinate(_ userCoordinate: CLLocationCoordinate2D) {
        ref.child("coordinates").child(user.uid).setValue(
            ["t": ServerValue.timestamp(), "v": serializeCoordinate(userCoordinate)])
    }
    
    func observeUserCoordinatesUpdated(with: @escaping (_ userCoordinates: [String: CLLocationCoordinate2D]) -> ()) {
        ref.child("coordinates").observe(DataEventType.value) { (snapshot) in
            let value = snapshot.value as? [String: NSDictionary]
            with(Dictionary(uniqueKeysWithValues: value?.compactMap({ pair in
                    let value = pair.value as? [String: AnyObject]
                    let v = value?["v"] as? NSDictionary
                    return v.flatMap({ v in self.deserializeCoordinate(v) })
                        .flatMap({ coordinate in (pair.key, coordinate) })
                }) ?? []
            ))
        }
    }
    
    private func serializeCoordinate(_ coordinate: CLLocationCoordinate2D) -> [String: NSNumber] {
        return ["lat": NSNumber(value: coordinate.latitude),
                "lon": NSNumber(value: coordinate.longitude)]
    }
    private func deserializeCoordinate(_ object: AnyObject) -> CLLocationCoordinate2D? {
        if let array = object as? [String: NSNumber] {
            if array["lat"] == nil || array["lon"] == nil {
                return nil
            }
            return CLLocationCoordinate2DMake(array["lat"]!.doubleValue, array["lon"]!.doubleValue)
        }
        return nil
    }
    
}
