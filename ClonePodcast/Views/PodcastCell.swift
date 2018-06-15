//
//  PodcastCell.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
   
   @IBOutlet weak var podcastImageView: UIImageView!
   @IBOutlet weak var trackNameLabel: UILabel!
   @IBOutlet weak var artistNameLabel: UILabel!
   @IBOutlet weak var EpisodeCountLabel: UILabel!
   
   
   var podcast: Podcast! {
      didSet {
         artistNameLabel.text = podcast.artistName
         trackNameLabel.text = podcast.trackName
         EpisodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
         
         guard let url = URL(string: podcast.artworkUrl60 ?? "") else { return }
         podcastImageView.sd_setImage(with: url, completed: nil)

      }
   }
   
}
