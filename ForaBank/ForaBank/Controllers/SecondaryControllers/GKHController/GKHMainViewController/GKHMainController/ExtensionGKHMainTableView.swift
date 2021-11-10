//
//  ExtensionGKHMainTableView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.08.2021.
//

import UIKit
import RealmSwift


extension GKHMainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedOrganization.count
        } else {
            return organization.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = searchedOrganization[indexPath.row]
            cell.set(viewModel: model)
        } else {
            let model = organization[indexPath.row]
            cell.set(viewModel: model)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.searchBar.searchTextField.endEditing(true)
        performSegue(withIdentifier: "input", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let op: GKHOperatorsModel!
        switch segue.identifier {
        
        case "input":
            // Если переход по нажатию на ячейку
            if self.tableView.indexPathForSelectedRow?.row != nil {
                let index = (self.tableView.indexPathForSelectedRow?.row)!
                if searching {
                    op = searchedOrganization[index]
                } else {
                    op = organization[index]
                }
                let dc = segue.destination as! GKHInputViewController
                dc.operatorData = op
            }
            // Переход по QR
            if (qrData.count != 0 && operators != nil) {
                let dc = segue.destination as! GKHInputViewController
               
                dc.operatorData = operators
                dc.qrData = qrData
                
            }
            qrData.removeAll()
        case "qr":
            let dc = segue.destination as! QRViewController
            dc.delegate = self
            
        case .none:
            print()
        case .some(_):
            print()
        }
        
    }
    
    func observerRealm() {
            operatorsList = realm?.objects(GKHOperatorsModel.self)
            self.token = self.operatorsList?.observe { [weak self] ( changes: RealmCollectionChange) in
                guard (self?.tableView) != nil else {return}
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tableView.endUpdates()
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        
    }
    
}

