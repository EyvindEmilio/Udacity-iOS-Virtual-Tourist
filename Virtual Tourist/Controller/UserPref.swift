//
//  UserPref.swift
//  Virtual Tourist
//
//  Created by Eyvind on 2/6/22.
//

import Foundation
import CoreLocation


class UserPref{
    private static let PREF_LAST_LAT = "PREF_LAST_LAT"
    private static let PREF_LAST_LONG = "PREF_LAST_LONG"
    private static let PREF_LAST_SPAN_LAT = "PREF_LAST_SPAN_LAT"
    private static let PREF_LAST_SPAN_LONG = "PREF_LAST_SPAN_LONG"
    
    static func getUserDef() -> UserDefaults {
        return UserDefaults.standard
    }
    
    static func setLastLocation(_ lat: Double, _ long: Double){
        getUserDef().set(lat, forKey: PREF_LAST_LAT)
        getUserDef().set(long, forKey: PREF_LAST_LONG)
    }
    
    static func setLastSpan(_ lat: Double, _ long: Double){
        getUserDef().set(lat, forKey: PREF_LAST_SPAN_LAT)
        getUserDef().set(long, forKey: PREF_LAST_SPAN_LONG)
    }
    
    static func getLastLocation() -> CustomLocation? {
        let lat = getUserDef().double(forKey: PREF_LAST_LAT)
        let long = getUserDef().double(forKey: PREF_LAST_LONG)
        
        if lat != 0 && long != 0 {
            return CustomLocation(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
    
    static func getLastSpanLocation() -> CustomLocation? {
        let lat = getUserDef().double(forKey: PREF_LAST_SPAN_LAT)
        let long = getUserDef().double(forKey: PREF_LAST_SPAN_LONG)
        
        if lat != 0 && long != 0{
            return CustomLocation(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
}
