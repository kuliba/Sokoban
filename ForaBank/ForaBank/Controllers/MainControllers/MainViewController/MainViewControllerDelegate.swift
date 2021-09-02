//
//  MainViewControllerDelegate.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section kind")
        }
        switch section {
        case .payments:
            print("DEBUG: " + #function + payments[indexPath.row].name)
                if let viewController = payments[indexPath.row].controllerName.getViewController() {
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
            }
        case .transfers:
            let viewController = ProductViewController()
                viewController.addCloseButton()
                let navVC = UINavigationController(rootViewController: viewController)
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true)
            
        case .offer:
            print("It's transfer")
        case .pay:
            print("its CurrencyExchange")
        case .openProduct:
            print("openProduct")
        case .branches: break
        case .investment: break
        case .services: break
        }
    }
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}



