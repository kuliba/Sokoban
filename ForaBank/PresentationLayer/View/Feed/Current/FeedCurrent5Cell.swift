//
//  FeedCurrent1Cell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FeedCurrent5Cell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    var videoLooper: AVPlayerLooper? = nil
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var subsubtitle: UILabel!
    @IBOutlet weak var position1name: UILabel!
    @IBOutlet weak var position1value: UILabel!
    @IBOutlet weak var position2name: UILabel!
    @IBOutlet weak var position2value: UILabel!
    @IBOutlet weak var position3name: UILabel!
    @IBOutlet weak var position3value: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = button.frame.height / 2
        
        let videoURL = Bundle.main.url(forResource: "feed_current_outlay", withExtension: ".mov")
        let asset = AVAsset(url: videoURL!)
        let item = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: item)
        videoLooper = AVPlayerLooper(player: player, templateItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = logoImageView.bounds
        logoImageView.layer.addSublayer(playerLayer)
        player.play()
    }
}



