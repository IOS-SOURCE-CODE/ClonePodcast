//
//  FavoritePodcastCell.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/20/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import UIKit


class FavoritePodcastCell: UICollectionViewCell {
   
   static let cellId = "CellID"
   
   let imageView = UIImageView(image: #imageLiteral(resourceName: "emptyImage"))
   let nameLabel = UILabel()
   let artistNameLabel = UILabel()
   
   
   var podcast: Podcast! {
      didSet {
         nameLabel.text = podcast.trackName
         artistNameLabel.text = podcast.artistName
         guard let url = URL(string: podcast.artworkUrl60 ?? "") else { return }
         imageView.sd_setImage(with: url, completed: nil)
      }
   }
   
   //MARK: - setup UI Function
   fileprivate func setupLabel() {
    
      nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
      artistNameLabel.font = UIFont.systemFont(ofSize: 13)
      artistNameLabel.textColor = .lightGray
   }
   
   fileprivate func setupViews() {
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
      
      let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
      stackView.axis = .vertical
      
      addSubview(stackView)
      
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
   }
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      setupLabel()
   
      setupViews()
      
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
}
