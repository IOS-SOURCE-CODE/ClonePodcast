//
//  SearchResult.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import Foundation


struct SearchResult: Decodable {
   let resultCount: Int
   let results: [Podcast]
}
