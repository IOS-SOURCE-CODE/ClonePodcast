//
//  RSSFeed.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import FeedKit

extension RSSFeed {
   func toEpisodes() -> [Episode]  {
      
      let imageUrl = iTunes?.iTunesImage?.attributes?.href
      
      var episodes = [Episode]()
      items?.forEach({ (item) in
         var episode = Episode(item: item)
         
         if episode.imageUrl == nil {
            episode.imageUrl = imageUrl
         }
         episodes.append(episode)
      })
      
      return episodes
   }
}


