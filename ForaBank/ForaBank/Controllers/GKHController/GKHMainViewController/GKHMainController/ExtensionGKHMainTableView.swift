//
//  ExtensionGKHMainTableView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.08.2021.
//

import UIKit

extension GKHMainViewController: UITableViewDelegate {
    
     func tableView(_ tableView: UITableView,
            viewForHeaderInSection section: Int) -> UIView? {
       let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                   "sectionHeader") as! GKHHistoryHeaderView
//       view.title.text = sections[section]
//       view.image.image = UIImage(named: sectionImages[section])

       return view
    }
}

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
       // tableView.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.searchTextField.endEditing(true)
        performSegue(withIdentifier: "input", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "input" else { return }

            let index = (self.tableView.indexPathForSelectedRow?.row)!
            let operators: GKHOperatorsModel?
        if searching {
            operators = searchedOrganization[index]
        } else {
            operators = organization[index]
        }
            let dc = segue.destination as! GKHInputViewController
            dc.operatorData = operators

    }
    
}

