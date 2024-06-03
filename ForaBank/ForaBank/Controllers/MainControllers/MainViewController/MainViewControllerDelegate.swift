//
//  MainViewControllerDelegate.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit
import AVFoundation
import SwiftUI

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section kind")
        }
        switch section {
        case .updateInfo: break // old code, not used
        case .products:
            switch productsViewModels[indexPath.item].name {
            case "Хочу карту":
                    guard let url = URL(string: "https://promo.forabank.ru/?metka=leads1&affiliate_id=44935&source=leads1&transaction_id=6dae603673619b0681e492d4bd1d8f3a" ) else { return  }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default:
                let productIndex = indexPath.item
                guard let products = self.realm?.objects(UserAllCardsModel.self), productIndex < products.count else {
                    return
                }
                
                var productsList = [UserAllCardsModel]()
                for product in products {
                    
                    productsList.append(product)
                }
            }
            
        case .offer:
                guard let url = URL(string: promoViewModels[indexPath.row].controllerName ) else { return  }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        case .currentsExchange:
            break

        case .pay:
            if indexPath.row == 0 {
                checkCameraAccess(isAllowed: {
                    if $0 {
                        DispatchQueue.main.async {
                            let controller = QRViewController.storyboardInstance()!
                            let nc = UINavigationController(rootViewController: controller)
                            nc.modalPresentationStyle = .fullScreen
                            self.present(nc, animated: true)
                        }
                    } else {
                        guard self.alertController == nil else {
                            return
                        }
                        self.alertController = UIAlertController(title: "Внимание", message: "Для сканирования QR кода, необходим доступ к камере", preferredStyle: .alert)
                        guard let alert = self.alertController else {
                            return
                        }
                        alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (action) in
                            self.alertController = nil
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            } else if indexPath.row == 1 {
                if let viewController = paymentsViewModels[indexPath.row].controllerName.getViewController() {
                    let navVC = UINavigationController(rootViewController: viewController)
                    present(navVC, animated: true)
                }
                
            } else if indexPath.row == 2 {
               
                //FIXME: inject from parent view model after refactoring
                let model = Model.shared
                let templatesViewModel = TemplatesListViewModel(model, dismissAction: {},
                                                                updateFastAll: {}
                )
                let templatesViewController = TemplatesListViewHostingViewController(with: templatesViewModel)
                templatesViewController.delegate = self
                let navigationViewController = UINavigationController(rootViewController: templatesViewController)
                present(navigationViewController, animated: true)
            }
            
        case .openProduct:
            if indexPath.row == 1 {
                
                /*
                let vc = OpenProductHostingViewController(with: .init(self.model, products: self.model.depositsProducts.value, style: .deposit))
                vc.hidesBottomBarWhenPushed = true
                let navigationViewController = UINavigationController(rootViewController: vc)
                present(navigationViewController, animated: true)
                 */

            } else {
                
                guard let url = URL(string: openProductViewModels[indexPath.row].controllerName ) else { return  }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .atm:
            guard let placesViewModel = PlacesViewModel(Model.shared) else {
                return
            }
            let placesHoustingController = UIHostingController(rootView: PlacesView(viewModel: placesViewModel))
            present(placesHoustingController, animated: true)
        }
    }

    func checkCameraAccess(isAllowed: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            // Доступ к камере не был дан
            isAllowed(false)
        case .restricted:
            isAllowed(false)
        case .authorized:
            // Есть разрешение на доступ к камере
            isAllowed(true)
        case .notDetermined:
            // Первый запрос на доступ к камере
            AVCaptureDevice.requestAccess(for: .video) { isAllowed($0) }
        @unknown default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let productCell = cell as? ProductCell {
            
            productCell.isUpdating = isUpdating.value
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let verticalOffset = scrollView.contentOffset.y
        if verticalOffset < -120.0 && isUpdating.value == false {
            
            startUpdate()
        }
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 490
        return presenter
    }
}

//MARK: - TemplatesListViewHostingViewControllerDelegate

extension MainViewController: TemplatesListViewHostingViewControllerDelegate {
    
    func presentProductViewController() {
        
        guard let products = self.realm?.objects(UserAllCardsModel.self), let firstProduct = products.first else {
            return
        }
        
        var productsList = [UserAllCardsModel]()
        for product in products {
            
            productsList.append(product)
        }
                
        let viewController = ProductViewController()

        delegate?.goProductViewController(product: firstProduct, products: productsList)
    }
}


