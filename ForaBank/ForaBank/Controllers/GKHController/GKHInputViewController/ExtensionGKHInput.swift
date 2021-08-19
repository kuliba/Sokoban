//
//  ExtensionGKHInput.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import UIKit

extension GKHInputViewController: UITableViewDelegate {
    
}

extension GKHInputViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
