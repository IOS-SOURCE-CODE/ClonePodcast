//
//  EpisodeTableViewController.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit
import FeedKit

class EpisodeTableViewController: UITableViewController {
   
   var podcast: Podcast? {
      didSet {
         navigationItem.title = podcast?.trackName
         fetchEpisodes()
      }
   }
   
   fileprivate let cellId = "CellID"
   
   var episodes = [Episode]()
   
   fileprivate func fetchEpisodes() {
      
      guard let feedUrl = podcast?.feedUrl else { return }
  
      APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
         self.episodes = episodes
         DispatchQueue.main.async {
            self.tableView.reloadData()
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupTableView()
      setupNavigationBarButton()
      
   }
   
   
   //MARK: - Setup  view
   fileprivate func setupNavigationBarButton() {
      navigationItem.rightBarButtonItems = [
         UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
//         UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavePodcast))
      ]
   }
   
   
   fileprivate func setupTableView() {
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
      let nib = UINib(nibName: "EpisodeCell", bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: cellId)
      tableView.tableFooterView = UIView()
   }
}

// MARK: - Table view data source
extension EpisodeTableViewController {
   
   override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      
      let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
      activityIndicatorView.color = .darkGray
      activityIndicatorView.startAnimating()
      return activityIndicatorView
   }
   
   override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return episodes.isEmpty ? 200 : 0
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return episodes.count
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let episode = episodes[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
      cell.episode = episode
      return cell
   }
   
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 132.0
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      tableView.deselectRow(at: indexPath, animated: true)
      let episode = episodes[indexPath.row]
      UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: episode, playingListEpisodes: self.episodes)
      
   }
}


// MARK: Handle Fetch and Save
extension EpisodeTableViewController {
   
   @objc fileprivate func handleFetchSavePodcast() {
      
      guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return }
      let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
      
      savedPodcasts?.forEach({print($0.trackName ?? "", $0.artistName ?? "")})
   }
   
   @objc fileprivate func handleSaveFavorite() {
      guard let podcast = self.podcast else { return }
      
      var listOfPodcast = UserDefaults.standard.savedPodcasts()
      listOfPodcast.append(podcast)
      
      let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcast)
      UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
   }
}









