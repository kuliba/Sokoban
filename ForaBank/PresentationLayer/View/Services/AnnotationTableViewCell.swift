//
//  AnnotationTableViewCell.swift
//  ForaBank
//
//  Created by Sergey on 22/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class AnnotationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var buttonRoute: UIButton!
    @IBOutlet weak var buttonCall: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup Buttons
        buttonRoute.backgroundColor = UIColor(hexFromString: "EE433C")
        buttonRoute.setTitle("маршрут", for: .normal)
        buttonRoute.setTitleColor(UIColor.white, for: .normal)
        buttonRoute.layer.cornerRadius = buttonRoute.frame.height/3
        
        buttonCall.backgroundColor = UIColor(hexFromString: "EE433C")
        buttonCall.setTitle("вызов", for: .normal)
        buttonCall.setTitleColor(UIColor.white, for: .normal)
        buttonCall.layer.cornerRadius = buttonCall.frame.height/3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(title: String?, address: String?, schedule: String?, phone: String?) {
        if let t = title {
            titleLabel.text = t
        }
        if let t = address {
            addressLabel.text = t
        }
        if let t = schedule {
            scheduleLabel.text = t
        }
        if let t = phone {
            phoneLabel.text = t
        }
        // нет телефона, нет кнопки
        if phone == nil || phone == ""{
            buttonCall.isUserInteractionEnabled = false
            buttonCall.alpha = 0
        }else{
            buttonCall.isUserInteractionEnabled = true
            buttonCall.alpha = 1
        }
    }

}

