//
//  MonthCollectionViewCell.swift
//  ForaBank
//
//  Created by Sergey on 29/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class MonthCollectionViewCell: UICollectionViewCell {
    
    let monthLabel: UILabel = {
        let l = UILabel()
        l.textColor = .lightGray
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override var isSelected: Bool {
        didSet {
            monthLabel.textColor = isSelected ? UIColor.black : UIColor.lightGray
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(monthLabel)
        
        contentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[monthLabel]|",
                                           options: [], metrics: nil, views: ["monthLabel":monthLabel]
        ))
        contentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[monthLabel]|",
                                           options: [], metrics: nil, views: ["monthLabel":monthLabel]
        ))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
