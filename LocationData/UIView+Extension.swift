//
//  UIView+Extension.swift
//  LocationData
//
//  Created by iMac on 2/14/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
  @IBInspectable var borderColor: UIColor? {
      get {
          guard let color = layer.borderColor
              else {
                  return nil
          }
          return UIColor(cgColor: color)
      }
      set {
          layer.borderColor = newValue?.cgColor
      }
  }
  @IBInspectable var borderWidth: CGFloat {
      get {
          return layer.borderWidth
      }
      set {
          layer.borderWidth = newValue
      }
  }

}
