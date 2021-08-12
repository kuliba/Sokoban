//
//  GKHDetailViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

class GKHDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
     var tableView: AdaptedTableView! {
        didSet {
            /// Инициализируем секции
            tableView.viewModel = GKHMainViewModel()
            /// Регистрируем ячейки
            tableView.cellFactory = MainSectionFactory()
            
            tableView.setup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tableView = AdaptedTableView()
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
    }

}
