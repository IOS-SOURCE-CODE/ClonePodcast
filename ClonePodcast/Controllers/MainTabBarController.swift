//
//  MainTabBarController.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/15/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      UINavigationBar.appearance().prefersLargeTitles = true
      tabBar.tintColor = .purple
      
      setupViewControllers()
      setupPlayerDetailView()
      
   }
   
   
   
   //MARK: - Setup Function
   let playerDetailView = PlayerDetailView.initFromNib()
   var minimizePlayerDetailTopConstraint: NSLayoutConstraint!
   var maxzimizePlayerDetailTopConstraint: NSLayoutConstraint!
   var bottomPlayerDetailConstraint: NSLayoutConstraint!
   
   fileprivate func setupPlayerDetailView() {
      
      view.insertSubview(playerDetailView, belowSubview: tabBar)
      playerDetailView.translatesAutoresizingMaskIntoConstraints = false
      
      bottomPlayerDetailConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
      bottomPlayerDetailConstraint.isActive = true
      
      playerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
      playerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
      
      
      // Maximize Player Detail top constraint
      maxzimizePlayerDetailTopConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
      maxzimizePlayerDetailTopConstraint.isActive = true
      
      
      // Minimize Player Detail top constraint
      minimizePlayerDetailTopConstraint = playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
      
      
   }
   
   
   
   
   @objc func minizePlayerDetailView() {
      
      maxzimizePlayerDetailTopConstraint.isActive = false
      bottomPlayerDetailConstraint.constant = view.frame.height
      minimizePlayerDetailTopConstraint.isActive = true
      
      animationlayout()
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         
         self.tabBar.transform = .identity
         self.playerDetailView.maximizeStackView.alpha = 0
         self.playerDetailView.miniPlayerView.alpha = 1
         
      }, completion: nil)
      
   }
   
   func maximizePlayerDetailView(episode: Episode?, playingListEpisodes: [Episode] = []) {
      
      minimizePlayerDetailTopConstraint.isActive = false
      maxzimizePlayerDetailTopConstraint.isActive = true
      maxzimizePlayerDetailTopConstraint.constant = 0
      bottomPlayerDetailConstraint.constant = 0
      
      animationlayout()
      
      if episode != nil {
         playerDetailView.episode = episode
      }
      
      playerDetailView.playlistEpisodes = playingListEpisodes
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         
         
         self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
         self.playerDetailView.maximizeStackView.alpha = 1
         self.playerDetailView.miniPlayerView.alpha = 0
         
      }, completion: nil)
      
   }
   
   
   func setupViewControllers() {
      
      let layout = UICollectionViewFlowLayout()
      let favoritesController = FavoritesViewController(collectionViewLayout: layout)
      let favoriteNavController = generateNavigationController(with: favoritesController, title: "Favorite", image: #imageLiteral(resourceName: "videoplayer"))
      
      let searchNavController = generateNavigationController(with: PodcastsSearchViewController(), title: "Search", image: #imageLiteral(resourceName: "search"))
     
      let downloadNavController = generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloaded"))
      
      viewControllers = [favoriteNavController,searchNavController, downloadNavController]
      
   }
   
   
   
   //MARK: - Helper Functions
   fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
      
      let navController = UINavigationController(rootViewController: rootViewController)
      navController.tabBarItem.title = title
      navController.tabBarItem.image = image
      //      navController.navigationBar.prefersLargeTitles = true
      rootViewController.navigationItem.title = title
      
      return navController
   }
   
   fileprivate func animationlayout() {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         self.view.layoutIfNeeded()
      }, completion: nil)
   }
   
}








