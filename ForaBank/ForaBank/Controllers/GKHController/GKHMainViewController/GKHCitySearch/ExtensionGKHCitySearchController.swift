//
//  ExtensionGKHCitySearchController.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.08.2021.
//

import UIKit

extension GKHCitySearchController: UITableViewDelegate {
    
}


extension GKHCitySearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedOrganization.count
        } else {
            return organization.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        if searching {
            cell.textLabel?.text = searchedOrganization[indexPath.row].region
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = organization[indexPath.row].region
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            self.searchText = searchedOrganization[indexPath.row].region ?? ""
        } else {
            self.searchText = organization[indexPath.row].region ?? ""
        }
        
    }
    
    
}
