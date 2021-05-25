//
//  DialogCell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 27/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DialogCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPicImageView: CircularImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var isReaded: UIImageView!
    @IBOutlet weak var messageNoReadCounterView: UIView!
    
    let userID = UserManager().currentUserID() ?? ""

    
    func set(_ conversation: ObjectConversation) {
      timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
        messageLabel.text = conversation.lastMessage
      guard let id = conversation.userIDs.filter({$0 != userID}).first else { return }
        
    let isRead = conversation.isRead[userID] ?? true
    let isReadOtherUser = conversation.isRead[id] ?? true
        if isReadOtherUser{
            isReaded.isHidden = false
        }
      if !isRead {
        userNameLabel.font = userNameLabel.font.bold
        messageLabel.font = messageLabel.font.bold
        timeLabel.font = timeLabel.font.bold
        messageNoReadCounterView.layer.cornerRadius = messageNoReadCounterView.frame.width/2
        messageNoReadCounterView.isHidden = false
        isReaded.isHidden = true
      } else {
        guard let lastMessage = conversation.lastMessage else {return}
        messageLabel.text = "Вы: \(lastMessage)"
        }
//      else {
//        guard let lastMessage = conversation.lastMessage else {return}
//        messageLabel.text = "Вы: \(lastMessage)"
//
//        }

        
      ProfileManager.shared.userData(id: id) {[weak self] profile in
        self?.userNameLabel.text = profile?.name
        guard let urlString = profile?.profilePicLink else {
//          self?.profilePic.image = UIImage(named: "profile pic")
          return
        }
//        self?.profilePic.setImage(url: URL(string: urlString))
      }
    }
    override func prepareForReuse() {
      super.prepareForReuse()
        userNameLabel.font = userNameLabel.font.regular
        messageLabel.font = messageLabel.font.regular
        timeLabel.font = timeLabel.font.regular
        messageNoReadCounterView.isHidden = true
        isReaded.isHidden = true
        
    }

}

class DateService {
  
  static let shared = DateService()
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
  }()
  
  private init() {}
  
  func format(_ date: Date) -> String {
    return dateFormatter.string(from: date)
 }
}


