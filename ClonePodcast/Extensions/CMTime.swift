//
//  CMTime.swift
//  ClonePodcast
//
//  Created by Hiem Seyha on 6/16/18.
//  Copyright © 2018 Hiem Seyha. All rights reserved.
//

import AVKit


extension CMTime {
   func toDisplay() -> String {
      let totalSecond = Int(CMTimeGetSeconds(self))
      let seconds = totalSecond % 60
      let minutes = totalSecond / 60
      let timeFormatString = String(format: "%02d:%02d",minutes, seconds)
      return timeFormatString
   }
}
