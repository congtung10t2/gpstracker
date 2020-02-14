//
//  LocationManager.swift
//  LocationData
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 iMac. All rights reserved.
//
import Foundation
import MapKit
import CoreLocation

class LocationManager: NSObject {
  
  static let shared = LocationManager();
  private var location: CLLocationManager?;
  public var isUpdating: Bool = false
   var currentLocationName: String = "abc"
  @objc dynamic var myLocation : CLLocation? = nil
  var locationData : [LocationModel] = []
  
  private override init() {
    super.init();
    location = CLLocationManager();
    location?.distanceFilter = 10;
  }
  
  func requestForLocation(){
    if let location = location {
      location.requestAlwaysAuthorization();
    }
  }
  
  var locationGranted: Bool? {
    return  CLLocationManager.locationServicesEnabled()
  }
  
  func acceptLocation() -> Bool {
    if self.locationGranted ?? false {
      let status = CLLocationManager.authorizationStatus()
      if status == .authorizedAlways || status == .authorizedWhenInUse {
        return true
      }
    }
    return false
  }
  
  func updatingLocation() {
    if LocationManager.shared.locationGranted == true {
      isUpdating = true
      LocationManager.shared.location?.delegate = self;
      LocationManager.shared.location?.startUpdatingLocation()
    }
  }
  
  func stopLocation() {
    isUpdating = false
    LocationManager.shared.location?.stopUpdatingLocation()
  }
}


extension LocationManager : CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations)
    if let location = locations.first {
      CoreDataManager.shared.save(locationModel: location.model(name: currentLocationName))
      
      
    }
    LocationManager.shared.myLocation = manager.location;
  }
}
extension CLLocation {
  func model(name: String) -> LocationModel {
    
    return LocationModel(name: name, lat: self.coordinate.latitude, lng: self.coordinate.longitude, altitude: self.altitude, timestamp: CLongLong(self.timestamp.timeIntervalSince1970), speed: self.speed, course: self.course, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy)
  }
}
