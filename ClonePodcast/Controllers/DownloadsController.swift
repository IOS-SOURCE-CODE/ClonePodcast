//
//  DownloadsController.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/20/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//




import UIKit

class DownloadController: UITableViewController {
   
   

   var episodes = [Episode]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupTableView()
      
      setupObserverProgressDownloading()
   
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      episodes = UserDefaults.standard.downloadedEpisodes()
      tableView.reloadData()
   }
}

//MARK: - setup UI
extension DownloadController {
   fileprivate func setupTableView() {
      
      let nib = UINib(nibName: "EpisodeCell", bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: EpisodeCell.cellId)
      tableView.tableFooterView = UIView()
   }
}


//MARK: - Data source and delegate
extension DownloadController {
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return episodes.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellId, for: indexPath) as! EpisodeCell
      cell.episode = episodes[indexPath.item]
      return cell
   }
   
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 134
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      tableView.deselectRow(at: indexPath, animated: true)
      
     let episode = self.episodes[indexPath.row]
      
      if episode.fileUrl != nil {
          UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: episode, playingListEpisodes: self.episodes)
      } else {
         let alertController = UIAlertController(title: "File URL not found", message: "Cannot find location file, playing using stream url instead ", preferredStyle: .actionSheet)
         let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            UIApplication.mainTabBarController()?.maximizePlayerDetailView(episode: episode, playingListEpisodes: self.episodes)
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         alertController.addAction(yesAction)
         alertController.addAction(cancelAction)
         present(alertController, animated: true)
      }
   }
   
   override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
      
      let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, index) in
         let episode = self.episodes[indexPath.row]
         
            do {

               guard let fileUrl = URL(string: episode.fileUrl ?? "") else { return }
               let fileName = fileUrl.lastPathComponent
               
               guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
               
               trueLocation.appendPathComponent(fileName)
               
               try FileManager.default.removeItem(at: trueLocation)
               
               UserDefaults.standard.deleteDownloadedEpisode(episode: episode)
               
               self.episodes.remove(at: indexPath.row)
               tableView.beginUpdates()
               tableView.deleteRows(at: [indexPath], with: .fade)
               tableView.endUpdates()
               
            } catch let error {
               debugPrint("Failed to delete file url \(episode.fileUrl ?? "" ): " , error)
            }
       
      }
      
      return [deleteAction]
   }
}


//MARK: - Observer progress downloading
extension DownloadController {
   fileprivate func setupObserverProgressDownloading() {
      
      NotificationCenter.default.addObserver(self, selector: #selector(handleProgress), name: .downloadProgress, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(handleProgressDownloadCompleted(notification:)), name: .downloadProgressCompleted, object: nil)
      
   }
   
    @objc fileprivate func handleProgressDownloadCompleted(notification: Notification) {
      guard let tuple = notification.object as? APIService.EpisodeDownlaodCompleteTuple else { return }
      
      guard let index = self.episodes.index(where: { $0.title == tuple.episodeTitle
      }) else { return }
      
      self.episodes[index].fileUrl = tuple.fileUrl
   }
   
   @objc fileprivate func handleProgress(notification: Notification) {
      guard let userInfo = notification.userInfo as? [String:Any] else { return }
      guard let progress = userInfo["progress"] as? Double else { return }
      guard let title = userInfo["title"] as? String else { return }
      
      guard let index = self.episodes.index(where: {
         $0.title == title
      }) else { return }
      
      guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
      
      cell.downloadProgressLabel.isHidden = false
      cell.downloadProgressLabel.text = "\(Int(progress * 100))%"
      
      if Int(progress) == 1 {
         cell.downloadProgressLabel.isHidden = true
      }
      
   }
}








