//
//  ExtensionGKHMainTableView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.08.2021.
//

import UIKit

extension GKHMainViewController: UITableViewDelegate {
    
    /// Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView( withIdentifier: GKHMainViewFooterView.reuseIdentifier) as? GKHMainViewFooterView
        else { return nil }
        return view
    }
    
    /// Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GKHMainViewHeader.reuseIdentifier) as? GKHMainViewHeader
        else {
            return nil
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 200.0
    }
}

extension GKHMainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operatorsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = (operatorsList?[indexPath.row])!
            cell.set(viewModel: model)
        } else {
            let model = (operatorsList?[indexPath.row])!
            cell.set(viewModel: model)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCountry: GKHOperatorsModel
        if searching {
            selectedCountry = searchedOrganization[indexPath.row]
        } else {
            selectedCountry = organization[indexPath.row]
        }
        self.searchController.searchBar.searchTextField.endEditing(true)
    }
    
}
