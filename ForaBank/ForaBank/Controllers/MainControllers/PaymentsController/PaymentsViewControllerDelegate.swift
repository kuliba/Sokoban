//
//  PaymentsViewControllerDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit

extension PaymentsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section kind")
        }
        switch section {
        case .payments:
            print("DEBUG: " + #function + payments[indexPath.row].name)
            if let viewController = payments[indexPath.row].controllerName.getViewController() {
                navigationController?.pushViewController(viewController, animated: true)
            }
        case .transfers:
            print("DEBUG: " + #function + transfers[indexPath.row].name)
            if let viewController = transfers[indexPath.row].controllerName.getViewController() {
                let navController = UINavigationController(rootViewController: viewController)
                if transfers[indexPath.row].name == "По номеру телефона"{
                    navController.modalPresentationStyle = .formSheet
                } else {
                    navController.modalPresentationStyle = .fullScreen

                }
                present(navController, animated: true, completion: nil)
                
//                navigationController?.pushViewController(viewController, animated: true)
            }
        case .pay:
            print("DEBUG: " + #function + pay[indexPath.row].name)
            if let viewController = pay[indexPath.row].controllerName.getViewController() {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
}
