//
//  CustomTableView.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 28/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setContentInset()
        removeExtraEmptyCells()
        
    }
}

// MARK: - Private methods
private extension CustomTableView {
    func backGroundColor() {
        backgroundColor = .white

    }
    func setContentInset() {
        contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func removeExtraEmptyCells() {
        tableFooterView = UIView()
    }
}
