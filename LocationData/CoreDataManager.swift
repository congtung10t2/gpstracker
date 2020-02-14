//
//  CoreData.swift
//  LocationData
//
//  Created by iMac on 2/12/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class CoreDataManager {
  static var shared = CoreDataManager()
  var locationData: [NSManagedObject] = []
  var locationAdded: [NSManagedObject] = []
  func save(locationModel: LocationModel) {
    
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    // 1
    let managedContext =
      appDelegate.persistentContainer.viewContext
    
    // 2
    let entity =
      NSEntityDescription.entity(forEntityName: "Location",
                                 in: managedContext)!
    
    let location = NSManagedObject(entity: entity,
                                 insertInto: managedContext)
    
    // 3
    location.setValue(locationModel.course, forKeyPath: "course")
    location.setValue(locationModel.altitude, forKeyPath: "altitude")
    location.setValue(locationModel.horizontalAccuracy, forKeyPath: "horizontalAccuracy")
    location.setValue(locationModel.lat, forKeyPath: "lat")
    location.setValue(locationModel.lng, forKeyPath: "lng")
    location.setValue(locationModel.verticalAccuracy, forKeyPath: "verticalAccuracy")
    location.setValue(locationModel.speed, forKeyPath: "speed")
    location.setValue(locationModel.timestamp, forKeyPath: "timestamp")
    location.setValue(locationModel.name, forKeyPath: "name")
    locationAdded.append(location)
    
  }
  func save() -> Bool{
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return false
    }
    let managedContext =
    appDelegate.persistentContainer.viewContext
    
    do {
      for location in locationAdded {
        managedContext.insert(location)
      }
      
      try managedContext.save()
      return true
    } catch {
      return false
    }
  }
  func cancel() {
    locationAdded = []
  }
  
  
  func retrieveData() {
    //1
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return 
    }
    
    let managedContext =
      appDelegate.persistentContainer.viewContext
    
    //2
    let fetchRequest =
      NSFetchRequest<NSManagedObject>(entityName: "Location")
    
    //3
    do {
      locationData = try managedContext.fetch(fetchRequest)
      for location in locationData {
        let model = location.locationModel
        print(model);
      }
      
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
}
extension NSManagedObject {
  var locationModel: LocationModel {

    let course = self.value(forKey: "course") as! Double
    let altitude = self.value(forKey: "altitude") as! Double
    let horizontalAccuracy = self.value(forKey: "horizontalAccuracy") as! Double
    let lat = self.value(forKey: "lat") as! Double
    let lng = self.value(forKey: "lng") as! Double
    let verticalAccuracy = self.value(forKey: "verticalAccuracy") as! Double
    let speed = self.value(forKey: "speed") as! Double
    let timestamp = self.value(forKey: "timestamp") as! CLongLong
    let name = self.value(forKey: "name") as! String
    return LocationModel(name: name, lat: lat, lng: lng, altitude: altitude, timestamp: timestamp, speed: speed, course: course, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy)
  }
}
