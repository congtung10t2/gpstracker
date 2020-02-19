//
//  Location.swift
//  LocationData
//
//  Created by iMac on 2/12/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import CoreData
@objc class LocationModel: NSObject, Codable{
  var name: String
  var lat: Double
  var lng: Double
  var altitude: Double
  var timestamp: CLongLong
  var speed: Double
  var course: Double
  var horizontalAccuracy: Double
  var verticalAccuracy: Double
  init(name: String?, lat: Double, lng: Double,altitude: Double, timestamp: CLongLong, speed: Double, course: Double, horizontalAccuracy: Double, verticalAccuracy: Double) {
    self.name = name ?? ""
    self.lat = lat
    self.lng = lng
    self.altitude = altitude
    self.timestamp = timestamp
    self.speed = speed
    self.course = course
    self.horizontalAccuracy = horizontalAccuracy
    self.verticalAccuracy = verticalAccuracy
  }
}
extension LocationModel {
  func getDateAsString() -> String {
    let exactDate = NSDate(timeIntervalSince1970: TimeInterval(truncating: NSNumber(integerLiteral: Int(CLongLong(self.timestamp)/1000) )))
     let dateFormatt = DateFormatter()
     dateFormatt.dateFormat = "dd/MM/yyy hh:mm:ss a"
    return dateFormatt.string(from: exactDate as Date)
  }
}
