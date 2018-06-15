//
//  PodcastsSearchViewController.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchViewController: UITableViewController {
   
   var podcasts:[Podcast] = []
   
   let cellId = "Cell"
   let searchController = UISearchController(searchResultsController: nil)
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupSearchBar()
      setupTableView()
      
   }
   
}
//MARK: - Setup UI
extension PodcastsSearchViewController {
   
   fileprivate func setupSearchBar() {
      self.definesPresentationContext = true
      navigationItem.searchController = searchController
      navigationItem.hidesSearchBarWhenScrolling = false
      searchController.dimsBackgroundDuringPresentation = false
      searchController.searchBar.delegate = self
   }
   
   fileprivate func setupTableView() {
      tableView.tableFooterView = UIView()
      let nib = UINib(nibName: "PodcastCell", bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: cellId)
   }
}

//MARK: - Table View Delegate
extension PodcastsSearchViewController {
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return podcasts.count
   }
   
   
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 132.0
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
      cell.podcast = podcasts[indexPath.row]
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      let podcast = podcasts[indexPath.row]
      let episodesVC = EpisodeTableViewController()
      episodesVC.podcast = podcast
      self.navigationController?.pushViewController(episodesVC, animated: true)
      
   }
   
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return podcasts.count > 0 ? 0 : 250.0
   }
   
   override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let label = UILabel()
      label.text = "Please enter a Search Text"
      label.textAlignment = .center
      label.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
      label.textColor = .purple
      return label
   }
}

//MARK: - Search Bar Delegate
extension PodcastsSearchViewController:  UISearchBarDelegate {
   
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
      APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
         self.podcasts = podcasts
         self.tableView.reloadData()
      }
      
   }
   
}















































