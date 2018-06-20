//
//  Notification.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/20/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation

extension Notification.Name {
   static let downloadProgress = NSNotification.Name(rawValue: "downloadProgress")
   static let downloadProgressCompleted = NSNotification.Name(rawValue: "downloadProgressCompleted")
}
