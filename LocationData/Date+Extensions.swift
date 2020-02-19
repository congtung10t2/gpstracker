//
//  Date+Extension.swift
//  LocationData
//
//  Created by iMac on 2/19/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
extension Date {
  var millisecondsSince1970:Int64 {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
  
  init(milliseconds:Int64) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
  }
}
