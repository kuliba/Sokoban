//
//  AdaptedTableViewDelegate.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

// MARK: - UITableViewDelegate

extension AdaptedTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectRowAt(indexPath: indexPath)
    }
    
}
