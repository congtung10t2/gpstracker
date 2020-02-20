//
//  Tracker.swift
//  LocationData
//
//  Created by iMac on 2/19/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import Firebase
class LocationRaw : Codable{
  var lat: Double!
  var lng: Double!
  var altitude: Double!
  var timestamp: CLongLong!
  var speed: Double!
  var course: Double!
  var horizontalAccuracy: Double!
  var verticalAccuracy: Double!
  
}
class Tracker : Codable {
  var name: String
  var data: [LocationRaw] = []
  init(locations: [LocationModel]) {
    for location in locations {
      let local = LocationRaw()
      local.lat = location.lat
      local.lng = location.lng
      local.altitude = location.altitude
      local.course = location.course
      local.speed = location.speed
      local.timestamp = location.timestamp
      local.horizontalAccuracy = location.horizontalAccuracy
      local.verticalAccuracy = location.verticalAccuracy
      self.data.append(local)
    }
    name = locations.first!.name;
  }
  func getDateAsString() -> String {
    let exactDate = NSDate(timeIntervalSince1970: TimeInterval(truncating: NSNumber(integerLiteral: Int(CLongLong(self.data.first!.timestamp)/1000) )))
     let dateFormatt = DateFormatter()
     dateFormatt.dateFormat = "dd-MM-yyy hh:mm:ss a"
    return dateFormatt.string(from: exactDate as Date)
  }
  func writeToFile(){
    do {
      let fileURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(name)
      let encoder = try JSONEncoder().encode(self)
      
      try encoder.write(to: fileURL)
    } catch {
      print("JSONSave error of \(error)")
    }
  }
  func getAllFiles(){
    let storage = Storage.storage()
    let storageRef = storage.reference()
    
  }
  func uploadToCloud(completion: @escaping (StorageMetadata?, Error?) -> Void){
    let storage = Storage.storage()
    let storageRef = storage.reference()
    var data: Data?
    do {
      let fileURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(name)
      
      let encoder = try JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      data = try encoder.encode(self)
    } catch {}
    // Create a reference to the file you want to upload
    let riversRef = storageRef.child("json/\(name+getDateAsString()).json")
    
    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = riversRef.putData(data!, metadata: nil) { (metadata, error) in
      guard let metadata = metadata else {
        completion(nil, error)
        return
      }
      CoreDataManager.shared.markItLoaded(name: self.name)
      completion(metadata, error)
     
    }
  }
  func uploadFile(){
    let storage = Storage.storage()
    var localFile: URL?
    // Create a storage reference from our storage service
    let storageRef = storage.reference()
    do {
      let fileURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name)
      localFile = fileURL
      
      
    } catch {
      
    }
    // Create a reference to the file you want to upload
    let riversRef = storageRef.child("data/\(name).json")
    
    // Upload the file to the path "images/rivers.jpg"
    let uploadTask = riversRef.putFile(from: localFile!, metadata: nil) { metadata, error in
      guard let metadata = metadata else {
        // Uh-oh, an error occurred!
        print("Uh-oh, an error occurred!")
        return
      }
      let size = metadata.size
      riversRef.downloadURL { (url, error) in
        guard let downloadURL = url else {
          
          print("// Uh-oh, an error occurred!")
          return
        }
      }
    }
  }
  func uploadObject(){
  }
}
