//
//  ExtensionGKHInput.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2021.
//

import UIKit

extension GKHInputViewController: UITableViewDataSource, TableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GKHInputCell.reuseId, for: indexPath) as! GKHInputCell
        
        guard dataArray.count != 0 else { return cell }
        cell.setupUI(indexPath.row, dataArray)
        
        if dataArray[indexPath.row]["value"] != nil {
            self.emptyArray.append(true)
        }
        
        cell.tableViewDelegate = (self as TableViewDelegate)
        cell.showInfoView = {[weak self] value in
            let infoView = GKHInfoView()
            infoView.label.text = value
            self?.showAlert(infoView)
        }
        cell.showGoButton = { [weak self] value in
            if value == true {
            
            self?.emptyArray.append(value)
                if self?.emptyArray.count ?? 0 > self?.dataArray.count ?? 0 {
                    self?.emptyArray.removeLast()
                }
            self?.empty()
                print("self?.emptyArray", self?.emptyArray.count ?? 0, value)
            } else {
                guard self?.emptyArray.count ?? 0 > 0 else {return}
                self?.emptyArray.removeLast()
                self?.empty()
            }
        }
        cell.pesrAccaunt = { [weak self] value in
            self?.personalAccount = value
        }
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
