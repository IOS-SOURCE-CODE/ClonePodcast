//
//  Episode.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation
import FeedKit

struct Episode : Codable {
   let title:String
   let pubDate:Date
   let description:String
   let author: String
   let streamUrl:String
   var imageUrl:String?
   var fileUrl:String?
   
   init(item: RSSFeedItem) {
      
      author = item.iTunes?.iTunesAuthor ?? ""
      title = item.title ?? ""
      streamUrl = item.enclosure?.attributes?.url ?? ""
      pubDate = item.pubDate ?? Date()
      description = item.iTunes?.iTunesSubtitle ?? item.description ?? ""
      imageUrl = item.iTunes?.iTunesImage?.attributes?.href
   }
}
