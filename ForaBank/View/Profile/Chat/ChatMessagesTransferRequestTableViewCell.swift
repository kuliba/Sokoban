//
//  TransferRequestTableViewCell.swift
//  ForaBank
//
//  Created by Sergey on 25/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ChatMessagesTransferRequestTableViewCell: UITableViewCell {

    let frameView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexFromString: "#F7F7F7")
        v.layer.cornerRadius = 5
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let messageLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 2
        l.font = UIFont.systemFont(ofSize: 14)//UIFont(name: "Roboto-Regular", size: 16)!
        l.textColor = .black
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Roboto-Regular", size: 13)!
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let sumLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 30)//UIFont(name: "Roboto-Regular", size: 20)!
        l.textColor = .black
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    let coinImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "chat_message_coin")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 22.5
        b.backgroundColor = .clear
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor(hexFromString: "D3D3D3")!.cgColor
        b.tintColor = .black
        b.setAttributedTitle(NSAttributedString(string: "Отправить", attributes: [.font:UIFont.systemFont(ofSize: 16)]), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(frameView)
        frameView.addSubview(messageLabel)
        frameView.addSubview(timeLabel)
        frameView.addSubview(coinImageView)
        frameView.addSubview(sumLabel)
        frameView.addSubview(sendButton)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[frameView]|", options: [], metrics: nil, views: ["frameView":frameView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[frameView]|", options: [], metrics: nil, views: ["frameView":frameView]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[coinImageView(41)]-7-[messageLabel]-10-[sumLabel]-10-[timeLabel]-15-|", options: [], metrics: nil, views: ["coinImageView":coinImageView, "messageLabel":messageLabel, "sumLabel":sumLabel, "timeLabel":timeLabel]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[sendButton]-15-|", options: [], metrics: nil, views: ["sendButton":sendButton]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sendButton(45)]-10-|", options: [], metrics: nil, views: ["sendButton":sendButton]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[coinImageView(41)]", options: [], metrics: nil, views: ["coinImageView":coinImageView]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[messageLabel(41)]", options: [], metrics: nil, views: ["messageLabel":messageLabel]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-17-[sumLabel(39)]", options: [], metrics: nil, views: ["sumLabel":sumLabel]))
        frameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-27-[timeLabel(29)]", options: [], metrics: nil, views: ["timeLabel":timeLabel]))
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
