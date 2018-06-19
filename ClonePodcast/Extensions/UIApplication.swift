//
//  UIApplication.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/19/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit

extension UIApplication {
   static func mainTabBarController() -> MainTabBarController? {
      return shared.keyWindow?.rootViewController as? MainTabBarController
   }
}
