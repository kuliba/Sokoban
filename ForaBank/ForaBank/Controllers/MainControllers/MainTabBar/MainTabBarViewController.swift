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
        
        let mainVC = MainViewController()
        let paymentsVC = PaymentsViewController()
        let historyVC = DevelopViewController()
        let chatVC = SettingsViewController()
        
        viewControllers = [
            generateNavController(rootViewController: mainVC,
                                  title: "Главный",
                                  image: UIImage(named: "tabBar-main")!,
                                  fillImage: UIImage(named: "tabBar-main-fill")!),
            
            generateNavController(rootViewController: paymentsVC,
                                  title: "Платежи",
                                  image: UIImage(named: "tabBar-card")!,
                                  fillImage: UIImage(named: "tabBar-card-fill")!),
            
            generateNavController(rootViewController: historyVC,
                                  title: "История",
                                  image: UIImage(named: "tabBar-history")!,
                                  fillImage: UIImage(named: "tabBar-history-fill")!),
            
            generateNavController(rootViewController: chatVC,
                                  title: "Чат",
                                  image: UIImage(named: "tabBar-chat")!,
                                  fillImage: UIImage(named: "tabBar-chat-fill")!),
        ]
        selectedIndex = 1
        
        loadCatalog()
        
    }
    
    private func generateNavController(rootViewController: UIViewController, title: String, image: UIImage, fillImage: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.selectedImage = fillImage
        return navigationVC
    }

    private func loadCatalog() {
        
        NetworkHelper.request(.getCountries) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let countries = model as? [CountriesList] else { return }
            Dict.shared.countries = countries
            print("DEBUG: Load Countries")
        }
        
        NetworkHelper.request(.getBanks) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let banks = model as? [BanksList] else { return }
            Dict.shared.banks = banks
            print("DEBUG: Load Banks")
        }
        
        NetworkHelper.request(.getPaymentSystemList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let paymentSystem = model as? [PaymentSystemList] else { return }
            Dict.shared.paymentList = paymentSystem
            print("DEBUG: Load Payments")
        }
        
        NetworkHelper.request(.getCurrencyList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let currencySystem = model as? [CurrencyList] else { return }
            Dict.shared.currencyList = currencySystem
            print("DEBUG: Load Currency")
        }
        
//        NetworkHelper.request(.getProductList) { cardList , error in
//            if error != nil {
//                self.showAlert(with: "Ошибка", and: error!)
//            }
//            guard let cardList = cardList as? [GetProductListDatum] else { return }
//            print("DEBUG: Load card list... Count is: ", cardList.count)
//        }
        
    }

}
