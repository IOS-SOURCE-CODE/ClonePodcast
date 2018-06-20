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
   static let downloadedEpisodesKey = "downloadedEpisodesKey"
   
   func downloadEpisode(episode: Episode) {
      
      do {
         var episodes = downloadedEpisodes()
         episodes.append(episode)
         
         let data = try JSONEncoder().encode(episodes)
         UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
         
      } catch let error {
         print("Failed to encode episode: ", error)
      }
   }
   
   func downloadedEpisodes() -> [Episode] {
      guard let episodeData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
      
      do {
         let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
         return episodes
         
      } catch let error {
         print("Failed to decode: ", error)
      }
      return []
   }
   
   func savedPodcasts() -> [Podcast] {
      guard let savePodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
      guard let savePodcasts = NSKeyedUnarchiver.unarchiveObject(with: savePodcastsData) as? [Podcast] else { return [] }
      return savePodcasts
   }
   
   func savePodcasts(listOfPodcasts: [Podcast]) {
      let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
      UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
   }
   
   func deletePodcast(podcast: Podcast) {
      let podcasts = savedPodcasts()
      let filterPodcasts = podcasts.filter { (p) -> Bool in
         return p.trackName != podcast.trackName && p.artistName != podcast.trackName
      }
      savePodcasts(listOfPodcasts: filterPodcasts)
   }
}
