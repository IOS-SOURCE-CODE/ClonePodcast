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
import MediaPlayer

class PlayerDetailView: UIView {
   
   // MARK: - Variable
   var episode: Episode! {
      didSet {
         miniEpisodeTitleLabel.text = episode.title
         titleLabel.text = episode.title
         authLabel.text = episode.author
         setupPlayInfo()
         playEpisode()
         
         guard let url = URL(string: episode.imageUrl ?? "") else { return }
         episodeImageView.sd_setImage(with: url, completed: nil)
         miniEpisodeImageview.sd_setImage(with: url, completed: nil)
         miniEpisodeImageview.sd_setImage(with: url) { (image, _, _, _) in
            guard let image = image else { return }
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
               return image
            })
            nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
         }
      }
   }
   
   let player: AVPlayer = {
      let avPlayer = AVPlayer()
      avPlayer.automaticallyWaitsToMinimizeStalling = false
      return avPlayer
   }()
   
   var panGesture: UIPanGestureRecognizer!
   
   fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
   
   fileprivate func playEpisode() {
      guard let url = URL(string: episode.streamUrl) else { return }
      let playerItem = AVPlayerItem(url: url)
      player.replaceCurrentItem(with: playerItem)
      player.play()
      
   }
   
   //MARK: - IBOutlet
   
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
       UIApplication.mainTabBarController()?.minizePlayerDetailView()
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
   
   
   //
   override func awakeFromNib() {
      super.awakeFromNib()
      
      setupRemoteControl()
      setupAudioSession()
      setupGestures()
      
      observePlayerCurrentTime()
      
      let time = CMTimeMake(1,3)
      let times = [NSValue(time: time)]
      
      // Retain cycle
      player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
         self?.enLargeEpisodeImageView()
      }
   }
   
}

//MARK: -  Self Helper
extension PlayerDetailView {
   static func initFromNib() -> PlayerDetailView {
      let playerDetailView = Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
      return playerDetailView
   }
}


//MARK: -  Audio Session
extension PlayerDetailView {
   
   fileprivate func setupRemoteControl() {
      UIApplication.shared.beginReceivingRemoteControlEvents()
      let commandCenter =  MPRemoteCommandCenter.shared()
      
      commandCenter.playCommand.isEnabled = true
      commandCenter.playCommand.addTarget { [weak self]  (_) -> MPRemoteCommandHandlerStatus in
         self?.player.play()
         self?.playpauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
         self?.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
         return .success
      }
      
      commandCenter.pauseCommand.isEnabled = true
      commandCenter.pauseCommand.addTarget { [weak self] (_) -> MPRemoteCommandHandlerStatus in
         self?.player.pause()
         self?.playpauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
         self?.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
         return .success
      }
   }
   
   fileprivate func setupAudioSession() {
      do {
         try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
         try AVAudioSession.sharedInstance().setActive(true)
      } catch let error {
         debugPrint("Faild to active audio session ", error)
      }
   }
   
   fileprivate func setupPlayInfo() {
      var nowPlayingInfo = [String:Any]()
      nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
      nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
   }
   
}
//MARK: -  Animation Helper
extension PlayerDetailView {
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
}


//MARK: -  Player Helper
extension PlayerDetailView {
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
         
         self?.setupLockscreenCurrentTime()
         
         self?.updateTimeSlider()
      }
   }
   
   fileprivate func updateTimeSlider() {
      let currentTimeSecond = CMTimeGetSeconds(player.currentTime())
      let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
      let percentage = currentTimeSecond / durationSeconds
      self.currentTimeSlider.value = Float(percentage)
   }
   
   fileprivate func setupLockscreenCurrentTime() {
      var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
      guard let currentItem = player.currentItem else { return }
      let durationInSecond = CMTimeGetSeconds(currentItem.duration)
      let elapsedTime = CMTimeGetSeconds(player.currentTime())
      nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime
      ] = elapsedTime
      nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSecond
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
   }
}

//MARK: -  Gesture Helper
extension PlayerDetailView {
   
   fileprivate func setupGestures() {
      addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMaximumPlayerDetail)))
      panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
      miniPlayerView.addGestureRecognizer(panGesture)
      
      maximizeStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan(gesture:))))
      
   }
   
   @objc func handleMaximumPlayerDetail() {
      UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: nil)
   }
   
   @objc func handlePan(gesture: UIPanGestureRecognizer) {
      
      if gesture.state == .changed {
         handlePandBegan(gesture)
      } else if gesture.state == .ended {
         handlePadEnded(gesture)
      }
   }
   
   
   fileprivate func handlePadEnded(_ gesture: UIPanGestureRecognizer) {
      let space : CGFloat = 200
      let translation = gesture.translation(in: self.superview)
      let velocity = gesture.velocity(in: self.superview)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         
         self.transform = .identity
         
         if translation.y < -space || velocity.y < -500 {
            UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: nil)
         } else {
            self.miniPlayerView.alpha = 1
            self.maximizeStackView.alpha = 0
         }
         
      })
   }
   
   fileprivate func handlePandBegan(_ gesture: UIPanGestureRecognizer) {
      let space : CGFloat = 200
      let translation = gesture.translation(in: self.superview)
      self.transform = CGAffineTransform.init(translationX: 0, y: translation.y)
      
      self.miniPlayerView.alpha = 1 + translation.y / space
      self.maximizeStackView.alpha = -translation.y / space
   }
   
   @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
      if gesture.state == .changed {
         let translation = gesture.translation(in: self.superview)
         maximizeStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
         debugPrint(translation.y)
      } else if gesture.state == .ended {
         
         let translation = gesture.translation(in: self.superview)
         
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.maximizeStackView.transform = .identity
            if translation.y > 200 {
                UIApplication.mainTabBarController()?.minizePlayerDetailView()
            }
            
         })
      }
   }
}









