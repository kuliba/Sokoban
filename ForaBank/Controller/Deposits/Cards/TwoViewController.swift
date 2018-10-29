//
//  TwoViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov on 22/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class TwoViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
}

private extension TwoViewController {
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 25
        tableView.contentInset.bottom = 25
    }
}

extension TwoViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollUserInfo = ["tableView": tableView]
        NotificationCenter.default.post(name: NSNotification.Name("TableViewScrolled"), object: nil, userInfo: scrollUserInfo as [AnyHashable: Any])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let labelView = UILabel()
        labelView.frame = cell.frame
        labelView.text = "Cell #\(indexPath.row)"
        cell.addSubview(labelView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
