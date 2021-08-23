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
        return operatorData?.parameterList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GKHInputCell.reuseId, for: indexPath) as! GKHInputCell
        guard operatorData?.parameterList.count != 0 else { return cell}
        cell.setupUI((operatorData?.parameterList[indexPath.row])!)
        
        return cell
    }
    
    
}
