//
//  PaymentsViewControllerSearchBarDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit

extension PaymentsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
        
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
        
    }
}
