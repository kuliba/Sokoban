//
//  ChatMessagesOutgoingTableViewCell.swift
//  ForaBank
//
//  Created by Sergey on 25/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ChatMessagesOutgoingTableViewCell: UITableViewCell {

    let frameView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexFromString: "#F7F7F7")
        v.layer.cornerRadius = 5
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        //v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let messageLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont(name: "Roboto-Regular", size: 14)!
        l.textColor = .black
        //l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Roboto-Regular", size: 13)!
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(frameView)
        frameView.addSubview(messageLabel)
        frameView.addSubview(timeLabel)
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[timeLabel(35)]-15-|", options: [], metrics: nil, views: ["timeLabel":timeLabel]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[timeLabel]-15-|", options: [], metrics: nil, views: ["timeLabel":timeLabel]))
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
