//
//  ExpandingTableViewCell.swift
//  ExpandingCell
//
//  Created by Alexis Creuzot on 13/11/2016.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import UIKit

class ExpandingTableViewCellContent {
    var title: String?
    var subtitle: String?
    var amountPerMonth: String?
    var loanPerMonth: String?
    var percentPM: String?
    var percentString: String?
    var expanded: Bool

    init(title: String, subtitle: String, amountPerMonth: String, loanPerMonth: String, percentPM: String, percentString: String) {
        self.title = title
        self.subtitle = subtitle
        self.amountPerMonth = amountPerMonth
        self.loanPerMonth = loanPerMonth
        self.percentPM = percentPM
        self.percentString = percentString
        self.expanded = false
        
    }
}

class ExpandingTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet weak var amountPerMonth: UILabel!
    @IBOutlet weak var percentPM: UILabel!
    @IBOutlet weak var loanPerMonth: UILabel!
    @IBOutlet weak var percentString: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(content: ExpandingTableViewCellContent) {
        self.titleLabel.text = content.title
        self.subtitleLabel.text = content.expanded ? content.subtitle : ""
        self.amountPerMonth.text = content.amountPerMonth
        self.percentPM.text = content.expanded ? content.percentPM : ""
         self.loanPerMonth.text = content.expanded ? content.loanPerMonth : ""
         self.percentString.text = content.expanded ? content.percentString : ""

    }
}
