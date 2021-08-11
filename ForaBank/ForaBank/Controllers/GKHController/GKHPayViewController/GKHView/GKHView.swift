//
//  GKHView.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

class GKHView: UITableViewController {
    
    let viewModel = GKHPayViewModel<[GKHPayModel]>()
    
    func setup () {
        viewModel.bind = {[weak self] data in
            print("уведомление", data as Any)
            
            self?.tableView.reloadData()
        }
        print("1")
        viewModel.fetch ()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
}
