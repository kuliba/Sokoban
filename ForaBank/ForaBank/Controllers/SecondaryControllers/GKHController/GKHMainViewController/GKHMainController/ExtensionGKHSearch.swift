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
    
    func doStringContainsNumber( _string : String) -> Bool{
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        return containsNumber
        
    }
}
