//
//  PlayerDetailView.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/16/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit

class PlayerDetailView: UIView {
   
   var episode: Episode! {
      didSet {
         titleLabel.text = episode.title
         authLabel.text = episode.author
         playEpisode()
         
         
         guard let url = URL(string: episode.imageUrl ?? "") else { return }
         episodeImageView.sd_setImage(with: url, completed: nil)
         
      }
   }
   
   let player: AVPlayer = {
   let avPlayer = AVPlayer()
   avPlayer.automaticallyWaitsToMinimizeStalling = false
   return avPlayer
   }()
   
   fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
   
   fileprivate func playEpisode() {
      guard let url = URL(string: episode.streamUrl) else { return }
      let playerItem = AVPlayerItem(url: url)
      player.replaceCurrentItem(with: playerItem)
      player.play()
      
   }
   
   fileprivate func enLargeEpisodeImageView() {
      UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         self.episodeImageView.transform = .identity
      }, completion: nil)
   }
   
   fileprivate func shrinkEpisodeImageView() {
      UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.episodeImageView.transform = self.shrunkenTransform
      }, completion: nil)
   }
   
   @IBOutlet weak var playpauseButton: UIButton! {
      didSet {
         self.episodeImageView.transform = self.shrunkenTransform
         playpauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
         playpauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
      }
   }
   
   
   
   @IBOutlet weak var episodeImageView: UIImageView! {
      didSet {
         episodeImageView.layer.cornerRadius = 5
         episodeImageView.clipsToBounds = true
        
      }
   }
   @IBOutlet weak var authLabel: UILabel!
   
   @IBAction func onDismiss(_ sender: Any) {
      self.removeFromSuperview()
   }
   
   @IBOutlet weak var currentTimeSlider: UISlider!
   @IBOutlet weak var currentTimeLabel: UILabel!
   @IBOutlet weak var durationLabel: UILabel!
   
   
   
   
   @IBOutlet weak var titleLabel: UILabel! {
      didSet {
         titleLabel.numberOfLines = 2
      }
      
   }
   
   @objc func handlePlayPause() {
      
      if player.timeControlStatus == .paused {
          playpauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
         player.play()
         self.enLargeEpisodeImageView()
      } else {
         playpauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
         player.pause()
         shrinkEpisodeImageView()
      }
   }
   
   
   fileprivate func observePlayerCurrentTime() {
      let interval = CMTimeMake(1, 2)
      player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
         
         self.currentTimeLabel.text = time.toDisplay()
         let durationTime = self.player.currentItem?.duration
         self.durationLabel.text = durationTime?.toDisplay()
         self.updateTimeSlider()
      }
   }
   
   fileprivate func updateTimeSlider() {
      let currentTimeSecond = CMTimeGetSeconds(player.currentTime())
      let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
      let percentage = currentTimeSecond / durationSeconds
      self.currentTimeSlider.value = Float(percentage)
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      observePlayerCurrentTime()
      
      let time = CMTimeMake(1,3)
      let times = [NSValue(time: time)]
      player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
         self.enLargeEpisodeImageView()
      }
   }
   
}
