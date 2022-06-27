//
//  Pin+extension.swift
//  Virtual Tourist
//
//  Created by Eyvind on 26/6/22.
//

import Foundation
import CoreData

extension Pin{
    static func newInstance(lat: Double, lon: Double, context: NSManagedObjectContext) -> Pin{
        let pin = Pin(context: context)
        pin.attempt = 1
        pin.lat = lat
        pin.lon = lon
        pin.photos = []
        return pin
    }
    
    func newCollection() {
        attempt += 1
    }
    
    func newInitialCollection(){
        attempt = 1
    }
}
