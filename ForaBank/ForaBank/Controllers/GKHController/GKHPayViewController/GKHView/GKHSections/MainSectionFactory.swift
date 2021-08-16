//
//  MainSectionFactory.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

protocol AdaptedSectionFactoryProtocol {
    var cellTypes: [AdaptedCellProtocol.Type] { get }
    func registerAllCells(_ tableView: UITableView)
    func generateCell(viewModel: AdaptedCellViewModelProtocol, tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
    func generateSection(viewModel: AdaptedSectionHeaderViewModelProtocol) -> UIView?
}

extension AdaptedSectionFactoryProtocol {
    
    func registerAllCells(_ tableView: UITableView) {
        cellTypes.forEach({ $0.register(tableView) })
    }
    
}

struct MainSectionFactory: AdaptedSectionFactoryProtocol {
    
    var cellTypes: [AdaptedCellProtocol.Type] = [
        GKHAnyCell.self
    ]
    
    func generateCell(viewModel: AdaptedCellViewModelProtocol, tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        switch viewModel {
        case let viewModel as GKHAnyCellViewModel:
            let view = GKHAnyCell.reuse(tableView, for: indexPath)
            view.viewModel = viewModel
            return view
        default:
            return UITableViewCell()
        }
    }
    
    func generateSection(viewModel: AdaptedSectionHeaderViewModelProtocol) -> UIView? {
        nil
    }
    
}
