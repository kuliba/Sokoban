//
//  AdaptedTableViewDataSource.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

// MARK: - UITableViewDataSource

extension AdaptedTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sections.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.sections[section].cells.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cellFactory = cellFactory,
            let cellViewModel = viewModel?.sections[indexPath.section].cells[indexPath.row]
        else {
            return UITableViewCell()
        }
        
        return cellFactory.generateCell(viewModel: cellViewModel, tableView: tableView, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard
//            let cellFactory = cellFactory,
//            let headerViewModel = viewModel?.sections[section].header
//        else {
//            return nil
//        }
//
//        return cellFactory.generateSection(viewModel: headerViewModel)
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard
//            let cellFactory = cellFactory,
//            let footerViewModel = viewModel?.sections[section].footer
//        else {
//            return nil
//        }
//
//        return cellFactory.generateSection(viewModel: footerViewModel)
//    }
    
}
