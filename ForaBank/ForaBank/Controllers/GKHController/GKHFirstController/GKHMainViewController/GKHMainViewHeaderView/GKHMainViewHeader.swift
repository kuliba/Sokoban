//
//  GKHMainViewHeader.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.08.2021.
//

import UIKit

final class GKHMainViewHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier: String = String(describing: self)

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
