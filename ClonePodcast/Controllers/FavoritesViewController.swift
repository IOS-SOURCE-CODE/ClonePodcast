//
//  FavoritesViewController.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/20/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit

class FavoritesViewController: UICollectionViewController {
   
   var podcasts = UserDefaults.standard.savedPodcasts()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupCollectionView()
      
   }
   
   
   //MARK: Setup Function
   fileprivate func setupCollectionView() {
      collectionView?.backgroundColor = .white
      collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastCell.cellId)
      
      let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
      collectionView?.addGestureRecognizer(gesture)
   }
   
   @objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer) {
    
      let location = gesture.location(in: collectionView)
      guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
      
      let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
      
      let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
         self.podcasts.remove(at: selectedIndexPath.item)
         self.collectionView?.deleteItems(at: [selectedIndexPath])
         
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      alertController.addAction(deleteAction)
      alertController.addAction(cancelAction)
      
      present(alertController, animated: true)
      
   }
   
   // MARK: Collection View Delegate and Data Source
   
   override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return podcasts.count
   }
   
   override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritePodcastCell.cellId, for: indexPath) as! FavoritePodcastCell
      cell.podcast = podcasts[indexPath.item]
      return cell
      
   }
   
   
}

// MARK: Collection View Delegate Flow Layout
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let width = (view.frame.width - 3 * 16) / 2
      return CGSize(width: width, height: width + 46)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 16
   }
}
