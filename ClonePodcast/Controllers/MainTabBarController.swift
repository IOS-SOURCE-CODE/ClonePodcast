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
      
      
    }
   
   
   
   //MARK: - Setup ViewControllers
   func setupViewControllers() {
      
      let searchNavController = generateNavigationController(with: PodcastsSearchViewController(), title: "Search", image: #imageLiteral(resourceName: "search"))
      
      let favoriteNavController = generateNavigationController(with: ViewController(), title: "Favorite", image: #imageLiteral(resourceName: "videoplayer"))
      
      let downloadNavController = generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloaded"))
      
      
      
      viewControllers = [
                         searchNavController,
                         favoriteNavController,
                         downloadNavController]
      
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
   
}








