//
//  MainViewControllerSearchBarDelegate.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import Foundation
import UIKit

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
        
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {}
}
