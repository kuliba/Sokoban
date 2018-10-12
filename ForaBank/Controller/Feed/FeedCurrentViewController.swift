//
//  FeedCurrentViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov on 11/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class FeedCurrentViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    
    let cellId1 = "FeedCurrent1Cell"
    let cellId2 = "FeedCurrent2Cell"
    let cellId3 = "FeedCurrent3Cell"
    let cellId4 = "FeedCurrent4Cell"
    let cellId5 = "FeedCurrent5Cell"
    let cellId6 = "FeedCurrent6Cell"
    
    
    var cellHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewDelegateAndDataSource()
        registerNibCell()
        
        cellHeight = view.frame.height - 80 // - 49
        
        tableView.decelerationRate = .normal
    }
    
    
}

// MARK: - UITableView DataSource and Delegate
extension FeedCurrentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath) as! FeedCurrent1Cell
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! FeedCurrent2Cell
            return cell
        }
        
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! FeedCurrent3Cell
            return cell
        }
        
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId4, for: indexPath) as! FeedCurrent4Cell
            return cell
        }
        
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId5, for: indexPath) as! FeedCurrent5Cell
            return cell
        }
        
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId6, for: indexPath) as! FeedCurrent6Cell
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
private extension FeedCurrentViewController {
    
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
        
        let nibCell4 = UINib(nibName: cellId4, bundle: nil)
        tableView.register(nibCell4, forCellReuseIdentifier: cellId4)
        
        let nibCell5 = UINib(nibName: cellId5, bundle: nil)
        tableView.register(nibCell5, forCellReuseIdentifier: cellId5)
        
        let nibCell6 = UINib(nibName: cellId6, bundle: nil)
        tableView.register(nibCell6, forCellReuseIdentifier: cellId6)
    }
}

