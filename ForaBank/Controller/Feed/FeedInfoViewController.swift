//
//  FeedInfoViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 12/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedInfoViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    let cellId1 = "FeedInfo1Cell"
    let cellId2 = "FeedInfo2Cell"
    let cellId3 = "FeedInfo3Cell"

    var cellHeight: CGFloat = 0
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewDelegateAndDataSource()
        registerNibCell()
        
        cellHeight = view.frame.height - 80 // - 49
        
        tableView.decelerationRate = .normal
    }
}

// MARK: - UITableView DataSource and Delegate
extension FeedInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath) as! FeedInfo1Cell
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! FeedInfo2Cell
            return cell
        }
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! FeedInfo3Cell
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        let minSpace: CGFloat = 10.0
        var mod: Double = 0
        if velocity.y > 1 {
            mod = 0.5
        } else if velocity.y < -1 {
            mod = -0.5
        }
        var cellToSwipe = Double(Float((scrollView.contentOffset.y)) / Float((cellHeight + minSpace))) + Double(0.5) + mod
        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(tableView.numberOfRows(inSection: 0)) {
            cellToSwipe = Double(tableView.numberOfRows(inSection: 0)) - Double(1)
        }
        let indexPath = IndexPath(row: Int(cellToSwipe), section:0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

// MARK: - Private methods
private extension FeedInfoViewController {
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func registerNibCell() {
        let nibCell1 = UINib(nibName: cellId1, bundle: nil)
        tableView.register(nibCell1, forCellReuseIdentifier: cellId1)
        
        let nibCell2 = UINib(nibName: cellId2, bundle: nil)
        tableView.register(nibCell2, forCellReuseIdentifier: cellId2)
        
        let nibCell3 = UINib(nibName: cellId3, bundle: nil)
        tableView.register(nibCell3, forCellReuseIdentifier: cellId3)
    }
}
