//
//  ExtensionGKHInput.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import UIKit

extension GKHInputViewController: UITableViewDelegate {
    
}

extension GKHInputViewController: UITableViewDataSource, TableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operatorData?.parameterList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GKHCardCell.reuseId, for: indexPath) as! GKHCardCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GKHInputCell.reuseId, for: indexPath) as! GKHInputCell
            guard operatorData?.parameterList.count != 0 else { return cell }
            
            cell.setupUI((operatorData?.parameterList[indexPath.row])!)
            cell.tableViewDelegate = (self as TableViewDelegate)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var hight: CGFloat = 80.0
        if indexPath.row == 3 {
            hight = 200
        }
        return hight
    }
}

extension GKHInputViewController {
    
    func afterClickingReturnInTextField(cell: GKHInputCell) {
        
        valueToPass = cell.textField.text
    }
}
