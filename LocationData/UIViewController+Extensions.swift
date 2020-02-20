//
//  UIViewController+Extensions.swift
//  LocationData
//
//  Created by iMac on 2/20/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
extension UIViewController {
  func showLoading() -> MBProgressHUD {
    return MBProgressHUD.showAdded(to: self.view, animated: true);
  }

  func hideLoading(hud : MBProgressHUD){
    hud.hide(animated: true);
  }
}
