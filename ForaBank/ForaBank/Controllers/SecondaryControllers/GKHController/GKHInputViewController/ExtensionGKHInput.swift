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
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 200
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operatorData?.parameterList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GKHInputCell.reuseId, for: indexPath) as! GKHInputCell
        guard operatorData?.parameterList.count != 0 else { return cell }
        
        cell.setupUI(indexPath.row, (operatorData?.parameterList[indexPath.row])!, qrData)
        cell.tableViewDelegate = (self as TableViewDelegate)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let hight: CGFloat = 80.0
        return hight
    }
    
}

extension GKHInputViewController {
    
    func afterClickingReturnInTextField(cell: GKHInputCell) {
        bodyValue.removeAll()
        bodyValue = cell.body
        bodyArray.append(bodyValue)

    }
}
