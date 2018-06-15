//
//  Episode.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
   let title:String
   let pubDate:Date
   let description:String
   var imageUrl:String?
   
   init(item: RSSFeedItem) {
      title = item.title ?? ""
      pubDate = item.pubDate ?? Date()
      description = item.description ?? ""
      imageUrl = item.iTunes?.iTunesImage?.attributes?.href
   }
}
