//
//  String.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation


extension String {
   func toSecureHttps() -> String {
     return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
   }
}
