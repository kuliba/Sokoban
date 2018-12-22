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
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var addressHeight: NSLayoutConstraint!
    @IBOutlet weak var scheduleHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(title: String?, address: String?, schedule: String?, phone: String?) {
        titleHeight.constant = 0
        addressHeight.constant = 0
        scheduleHeight.constant = 0
        phoneHeight.constant = 0
        if let t = title {
            titleLabel.text = t
            titleHeight.constant = 20
        }
        if let t = address {
            addressLabel.text = t
            addressHeight.constant = 20
        }
        if let t = schedule {
            scheduleLabel.text = t
            scheduleHeight.constant = 20
        }
        if let t = phone {
            phoneLabel.text = t
            phoneHeight.constant = 20
        }
    }

}
