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
         
         setupAudioSession()
         
         playEpisode()
         
         guard let url = URL(string: episode.imageUrl ?? "") else { return }
         episodeImageView.sd_setImage(with: url, completed: nil)
         miniEpisodeImageview.sd_setImage(with: url, completed: nil)
         
         miniEpisodeImageview.sd_setImage(with: url) { (image, _, _, _) in
            
            let image = self.episodeImageView.image ?? UIImage()
            
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
               return image
            })
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
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
      
      if episode.fileUrl != nil {
         
        playEpisodeWithFileUrl()
         
      } else {
         
         guard let url = URL(string: episode.streamUrl) else { return }
         let playerItem = AVPlayerItem(url: url)
         player.replaceCurrentItem(with: playerItem)
         player.play()
         
      }
   }
   
   fileprivate func playEpisodeWithFileUrl() {
      
      guard let fileUrl = URL(string: episode.fileUrl ?? "") else { return }
      let fileName = fileUrl.lastPathComponent
      
      guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
      
      trueLocation.appendPathComponent(fileName)
      
      let playerItem = AVPlayerItem(url: trueLocation)
      player.replaceCurrentItem(with: playerItem)
      player.play()
   }

   var playlistEpisodes = [Episode]()
   
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
      
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSecond
      
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
   
   
   //MARK: Defult Method
   override func awakeFromNib() {
      super.awakeFromNib()
      
      setupRemoteControl()
      setupGestures()
      setupInterruptionObserver()
      
      observePlayerCurrentTime()
      
      observerBoundaryTime()
   }
   
}


//MARK: -  UI Helper
extension PlayerDetailView {
   
   static func initFromNib() -> PlayerDetailView {
      let playerDetailView = Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
      return playerDetailView
   }
   
   func stylePausePlayer() {
      self.playpauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
   }
   
   func stylePlayingPlayer() {
      self.playpauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "playing"), for: .normal)
   }
}


//MARK: -  Audio Session
extension PlayerDetailView {
   
   fileprivate func setupRemoteControl() {
      UIApplication.shared.beginReceivingRemoteControlEvents()
      let commandCenter =  MPRemoteCommandCenter.shared()
      
      commandCenter.playCommand.isEnabled = true
      commandCenter.playCommand.addTarget {  (_) -> MPRemoteCommandHandlerStatus in
         self.player.play()
        
         self.stylePlayingPlayer()
         
         self.setupElapseTime(playbackRate: 1)
         
         return .success
      }
      
      commandCenter.pauseCommand.isEnabled = true
      commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
         self.player.pause()
         
        self.stylePausePlayer()
         
         self.setupElapseTime(playbackRate: 0)
         
         return .success
      }
      
      commandCenter.togglePlayPauseCommand.isEnabled = true
      commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
         
         self.handlePlayPause()
         return .success
      }
      
      commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
      commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
      
   }
   
   @objc func handlePreviousTrack() {

      handleTrack { (index) -> Episode in
         if index == 0 {
          return  playlistEpisodes[playlistEpisodes.count - 1]
         } else {
           return playlistEpisodes[index - 1]
         }
      }
      
   }
   
   // Dry : Don't repeat yourself
   @objc func handleNextTrack() {
      
      handleTrack { (index) -> Episode in
         if index == playlistEpisodes.count - 1 {
               return playlistEpisodes[0]
            } else {
              return playlistEpisodes[index + 1]
            }
      }
   }
   
   
   // Instance Method
   fileprivate func handleTrack(check nextOrPrevious: (_ withIndex: Int) -> Episode) {
      
      if playlistEpisodes.count == 0 {
         return
      }
    
      let currentEpisodeIndex = playlistEpisodes.index { ep in
         return self.episode.title == ep.title && self.episode.author == ep.author
      }
      
      guard let index = currentEpisodeIndex else { return }
      
      self.episode = nextOrPrevious(index)
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
   
   fileprivate func setupElapseTime(playbackRate: Float) {
      let elapseTime = CMTimeGetSeconds(player.currentTime())
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapseTime
      
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
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
   
   fileprivate func observerBoundaryTime() {
      let time = CMTimeMake(1,3)
      let times = [NSValue(time: time)]
      
      // Retain cycle
      player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
         self?.enLargeEpisodeImageView()
         self?.setupLockscreenCurrentTime()
      }
      
      
      NotificationCenter.default.addObserver(self, selector: #selector(nextEpisode), name: .AVPlayerItemDidPlayToEndTime, object: nil)
   }
   
   
   @objc fileprivate func nextEpisode() {
      
     self.stylePausePlayer()
      
       let index = self.playlistEpisodes.index { [weak self] ep  in
          return ep.title == self?.episode.title && ep.streamUrl == self?.episode.streamUrl
      }
      
      guard let currentIndex = index else { return }
   
      if self.playlistEpisodes.count > currentIndex + 1 {
          self.episode = self.playlistEpisodes[currentIndex + 1]
      } else {
         self.episode = self.playlistEpisodes[0]
      }
   
      self.stylePlayingPlayer()
      playEpisode()
      
   }
   
   
   fileprivate func seekToCurrentTime(delta: Int64) {
      let fifteenSeconds = CMTimeMake(delta, 1)
      let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
      player.seek(to: seekTime)
   }
   
   
   
   @objc func handlePlayPause() {
      
      if player.timeControlStatus == .paused {
         self.stylePlayingPlayer()
         player.play()
         self.enLargeEpisodeImageView()
         self.setupElapseTime(playbackRate: 1)
      }
      
      else {
         self.stylePausePlayer()
         player.pause()
         shrinkEpisodeImageView()
         self.setupElapseTime(playbackRate: 0)
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
   
   fileprivate func setupLockscreenCurrentTime() {
      guard let duration = player.currentItem?.duration else { return }
      let durationInSecond = CMTimeGetSeconds(duration)
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSecond
   }
   
   fileprivate func setupInterruptionObserver() {
      NotificationCenter.default.addObserver(self, selector: #selector(hadleInteruption), name: .AVAudioSessionInterruption, object: nil)
   }
   
   @objc fileprivate func hadleInteruption(notification: Notification) {
      guard let userInfo = notification.userInfo else { return }
      guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
      if type == AVAudioSessionInterruptionType.began.rawValue {
        self.stylePausePlayer()
         
      } else {
         
         guard let options = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
         
         if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
            player.play()
            self.stylePlayingPlayer()
         }
         
         
      }
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
      UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: nil, playingListEpisodes: self.playlistEpisodes)
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
            UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: nil, playingListEpisodes: self.playlistEpisodes)
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









