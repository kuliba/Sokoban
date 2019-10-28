//
//  ChatMessagesIncomingTableViewCell.swift
//  ForaBank
//
//  Created by Sergey on 25/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ChatMessagesIncomingTableViewCell: UITableViewCell {

    let frameView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexFromString: "#EC4442")
        v.layer.cornerRadius = 5
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        //v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let messageLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 14)//UIFont(name: "Roboto-Regular", size: 16)!
        l.textColor = .white
        l.lineBreakMode = .byWordWrapping
        //l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Roboto-Regular", size: 13)!
        l.textColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let confirmImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "chat_message_confirm")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(frameView)
        frameView.addSubview(messageLabel)
        frameView.addSubview(timeLabel)
        frameView.addSubview(confirmImageView)
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[timeLabel(35)]-0-[confirmImageView(15)]-15-|", options: [], metrics: nil, views: ["timeLabel":timeLabel, "confirmImageView":confirmImageView]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[timeLabel(12)]-17-|", options: [], metrics: nil, views: ["timeLabel":timeLabel]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[confirmImageView(12)]-17-|", options: [], metrics: nil, views: ["confirmImageView":confirmImageView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
