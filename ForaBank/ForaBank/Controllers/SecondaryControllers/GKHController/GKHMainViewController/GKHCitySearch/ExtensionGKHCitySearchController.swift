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
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let a = tempArray
        cell.textLabel?.text = tempArray[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchText = tempArray[indexPath.row]
        dismiss(animated: true, completion: {
            if self.searching {
                NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key" : self.searchText])
            } else {
                if self.searchText != "" {
                    NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key" : self.searchText])
                }
            }
        })
    }
    
    
}
