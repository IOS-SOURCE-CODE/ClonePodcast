//
//  APIService.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
   private init() {}
   
   static let shared = APIService()
   
   let baseiTuneSearchURl = "https://itunes.apple.com/search"
   
   func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
      
      let secureUrl = feedUrl.toSecureHttps()
      guard let url = URL(string: secureUrl) else { return }
     
      
      DispatchQueue.global(qos: .background).async {
         
         let parser = FeedParser(URL: url)
         parser.parseAsync { (result) in
            if let error = result.error {
               print("Failed to parse xml feed:", error)
               return
            }
            guard let feed = result.rssFeed else { return }
            completion(feed.toEpisodes())
            
         }
      }
   }
   
   func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> ()) {
    
      let paramaters: Parameters = ["term": searchText, "media": "podcast"]
      
      Alamofire.request(baseiTuneSearchURl, method: .get, parameters: paramaters, encoding: URLEncoding.default , headers: nil).responseData { (dataResponse) in
         
         if let error = dataResponse.error {
            print("Failed to contact yahoo ", error)
            return
         }
         
         guard let data = dataResponse.data else { return }
         
         do {
            
            let resultSearch = try JSONDecoder().decode(SearchResult.self, from: data)
           completion(resultSearch.results)
            
         } catch let decodeErr {
            print("Failed to decode: ", decodeErr)
         }
      }
   }
}
