//
//  ExtensionGKHSearch.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.08.2021.
//

import UIKit

//MARK: - UISearchBarDelegate
extension GKHMainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !doStringContainsNumber(_string: searchText) {
        searchedOrganization = organization.filter { $0.name?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased() }
        } else {
            searchedOrganization = organization.filter { $0.synonymList.first?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased() }
        }
        searching = true
            
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
