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
        case .products:
            switch products[indexPath.item].id {
            case 32:
                if products[indexPath.item].name == "Cм.все"{
                    let viewController = ProductsViewController()
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                } else {
                    guard let url = URL(string: "https://promo.forabank.ru/?metka=leads1&affiliate_id=44935&source=leads1&transaction_id=6dae603673619b0681e492d4bd1d8f3a" ) else { return  }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            default:
                let viewController = ProductViewController()
    //            viewController.addCloseButton()
                viewController.delegate = self
                viewController.indexItem = indexPath.item
                viewController.product = productList[indexPath.item]
                
                let first3Elements :  [GetProductListDatum] // An Array of up to the first 3 elements.
                if productList.count >= 3 {
                    first3Elements = Array(productList[0 ..< 3])
                    viewController.products = first3Elements
                } else {
                    viewController.products = productList
                    first3Elements = productList
                    
                }
//                viewController.products = productList
                
                let navVC = UINavigationController(rootViewController: viewController)
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true)
            }
        case .offer:
            guard let url = URL(string: offer[indexPath.row].controllerName ) else { return  }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .currentsExchange:
            print("Currency")

//        case .transfers:
//            let viewController = ProductViewController()
//                viewController.addCloseButton()
//                let navVC = UINavigationController(rootViewController: viewController)
//                navVC.modalPresentationStyle = .fullScreen
//                present(navVC, animated: true)
//            
//        case .offer:
//            print("It's transfer")
        case .pay:
            if indexPath.row == 1{
                if let viewController = pay[indexPath.row].controllerName.getViewController() {
                    let navVC = UINavigationController(rootViewController: viewController)
                    present(navVC, animated: true)
            }
            } else {
                print("Pay")
            }
        case .openProduct:
            guard let url = URL(string: openProduct[indexPath.row].controllerName ) else { return  }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
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



