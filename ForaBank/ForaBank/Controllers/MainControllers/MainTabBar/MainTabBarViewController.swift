//
//  MainTabBarViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = .white
        tabBar.tintColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        
        let mainVC = DevelopViewController()
        let paymentsVC = PaymentsViewController()
        let historyVC = DevelopViewController()
        let chatVC = DevelopViewController()
        
        viewControllers = [
            generateNavController(rootViewController: mainVC,
                                  title: "Главный", image: #imageLiteral(resourceName: "foralogoTapBar")),
            
            generateNavController(rootViewController: paymentsVC,
                                  title: "Платежи", image: #imageLiteral(resourceName: "credit-card")),
            
            generateNavController(rootViewController: historyVC,
                                  title: "История", image: #imageLiteral(resourceName: "rotate-ccw")),
            
            generateNavController(rootViewController: chatVC,
                                  title: "Чат", image: #imageLiteral(resourceName: "message-circle")),
        ]
        selectedIndex = 1
        
        loadCatalog()
        
    }
    
    private func generateNavController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }

    private func loadCatalog() {
        
        NetworkHelper.request(.getCountries) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            print("DEBUG: Load Countries")
        }
        
        
        NetworkHelper.request(.getProductList) { cardList , error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let cardList = cardList as? [GetProductListDatum] else { return }
            print("DEBUG: Load card list... Count is: ", cardList.count)
        }
        
    }

}
