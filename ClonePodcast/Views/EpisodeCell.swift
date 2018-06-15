//
//  EpisodeCell.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {

   @IBOutlet weak var episodeImageView: UIImageView!
   @IBOutlet weak var pubDateLabel: UILabel!
   @IBOutlet weak var titleLabel: UILabel! {
      didSet {
         titleLabel.numberOfLines = 2
      }
   }
   @IBOutlet weak var descriptionLabel: UILabel! {
      didSet {
         descriptionLabel.numberOfLines = 2
      }
   }
   
   var episode: Episode! {
      didSet {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMM dd, yyyy"
         let pubDate = dateFormatter.string(from: episode.pubDate)
         
         pubDateLabel.text = "\(pubDate ) "
         titleLabel.text = "\(episode.title) "
         descriptionLabel.text = "\(episode.description)"
         
         let url = URL(string: (episode.imageUrl?.toSecureHttps())!)
         episodeImageView.sd_setImage(with: url, completed: nil)
        
      }
   }
   
   
}
