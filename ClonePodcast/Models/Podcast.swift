//
//  Podcast.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
   var trackName: String?
   var artistName: String?
   var artworkUrl60:String?
   var trackCount:Int?
   var feedUrl:String?
   
   func encode(with aCoder: NSCoder) {
      aCoder.encode(trackName ?? "" , forKey: "trackNameKey")
      aCoder.encode(artistName ?? "" , forKey: "artistNameKey")
      aCoder.encode(artworkUrl60 ?? "" , forKey: "artworkUrlKey")
      aCoder.encode(feedUrl ?? "" , forKey: "feedUrlKey")
   }
   
   required init?(coder aDecoder: NSCoder) {
      self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
      self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
      self.artworkUrl60 = aDecoder.decodeObject(forKey: "artworkUrlKey") as? String
      self.feedUrl = aDecoder.decodeObject(forKey: "feedUrlKey") as? String
   }
}




