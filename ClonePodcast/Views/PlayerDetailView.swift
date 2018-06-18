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
         miniEpisodeTitleLabel.text = episode.title
         
         titleLabel.text = episode.title
         authLabel.text = episode.author
         playEpisode()
         
         
         guard let url = URL(string: episode.imageUrl ?? "") else { return }
         episodeImageView.sd_setImage(with: url, completed: nil)
         miniEpisodeImageview.sd_setImage(with: url, completed: nil)
         
         
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
   
   
   
   
   //MARK: - Mini Player Action and Outlet
   
   @IBOutlet weak var miniEpisodeImageview: UIImageView!
   @IBOutlet weak var miniEpisodeTitleLabel: UILabel!
   @IBOutlet weak var miniPlayPauseButton: UIButton! {
      didSet {
         miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
      }
   }
   @IBOutlet weak var miniFastForwardButton: UIButton! {
      didSet {
         miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
      }
   }
   
   
   //MARK: - IBOutlet
   
   @IBOutlet weak var miniPlayerView: UIView!
   @IBOutlet weak var maximizeStackView: UIStackView!
   
   
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
   @IBOutlet weak var currentTimeSlider: UISlider!
   @IBOutlet weak var currentTimeLabel: UILabel!
   @IBOutlet weak var durationLabel: UILabel!
   @IBOutlet weak var titleLabel: UILabel! {
      didSet {
         titleLabel.numberOfLines = 2
      }
      
   }
   
   //MARK: - IBAction
   @IBAction func onDismiss(_ sender: Any) {
      let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
      mainTabBarController?.minizePlayerDetailView()
   }
   
   
   @IBAction func handleCurrentTimeSlider(_ sender: Any) {
      
      let percentage = currentTimeSlider.value
      guard let duration = player.currentItem?.duration else { return }
      let durationInSecond = CMTimeGetSeconds(duration)
      let seekTimeInSecond = Float64(percentage) * durationInSecond
      let seekTime = CMTimeMakeWithSeconds(seekTimeInSecond, 1)
      player.seek(to: seekTime)
   }
   
   
   @IBAction func handleRewind(_ sender: Any) {
      seekToCurrentTime(delta: -15)
   }
   
   @IBAction func handleFastForward(_ sender: Any) {
      seekToCurrentTime(delta: 15)
   }
   
   @IBAction func handleValumeChangeSlider(_ sender: UISlider) {
      player.volume = sender.value
   }
   
   
   
   fileprivate func seekToCurrentTime(delta: Int64) {
      let fifteenSeconds = CMTimeMake(delta, 1)
      let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
      player.seek(to: seekTime)
   }
   
   
   
   @objc func handlePlayPause() {
      
      if player.timeControlStatus == .paused {
         playpauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
          miniPlayPauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
         player.play()
         self.enLargeEpisodeImageView()
      } else {
         playpauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
         player.pause()
         shrinkEpisodeImageView()
      }
   }
   
   
   fileprivate func observePlayerCurrentTime() {
      let interval = CMTimeMake(1, 2)
      player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
         
         self?.currentTimeLabel.text = time.toDisplay()
         let durationTime = self?.player.currentItem?.duration
         self?.durationLabel.text = durationTime?.toDisplay()
         self?.updateTimeSlider()
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
      
     addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMaximumPlayerDetail)))
      
      observePlayerCurrentTime()
      
      let time = CMTimeMake(1,3)
      let times = [NSValue(time: time)]
      
      // Retain cycle
      player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
         self?.enLargeEpisodeImageView()
      }
   }
   
   deinit {
      print("Player Detail View memory being reclaimed....")
   }
   
   
   static func initFromNib() -> PlayerDetailView {
      let playerDetailView = Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
      return playerDetailView
   }
   
   @objc func handleMaximumPlayerDetail() {
      let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
      mainTabBarController?.maximizePlayerDetailView(episode: nil)
   }
}
