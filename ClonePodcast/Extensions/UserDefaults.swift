//
//  UserDefaults.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/20/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation


extension UserDefaults {
   static let favoritedPodcastKey = "favoritePodcastKey"
   
   func savedPodcasts() -> [Podcast] {
      guard let savePodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
      guard let savePodcasts = NSKeyedUnarchiver.unarchiveObject(with: savePodcastsData) as? [Podcast] else { return [] }
      return savePodcasts
   }
}
