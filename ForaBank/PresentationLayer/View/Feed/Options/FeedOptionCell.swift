//
//  FeedOptionCell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 10/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

protocol FeedOptionCellDelegate: class {
    func didChangedSwitch(at indexPath: IndexPath)
}

class FeedOptionCell: UITableViewCell {

    public struct Constants {
        public static let cellReuseIdentifier: String = "FeedOptionCell"
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var `switch`: UISwitch!

    @IBAction func changePinCode(_ sender: Any) {
        if let nonNilIndexPath = indexPath {
            delegate?.didChangedSwitch(at: nonNilIndexPath)
        }
    }

    weak var delegate: FeedOptionCellDelegate?
    var isToggable: Bool? {
        didSet {
            self.switch.isHidden = !(isToggable ?? true)
        }
    }
    var indexPath: IndexPath?
}
