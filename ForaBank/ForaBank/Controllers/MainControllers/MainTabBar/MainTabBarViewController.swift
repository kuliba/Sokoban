//
//  MainTabBarViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit
import RealmSwift

class MainTabBarViewController: UITabBarController {
    
    let mainVC = MainViewController()
    let paymentsVC = PaymentsViewController()
    let historyVC = DevelopViewController()
    let chatVC = ChatViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загрузка пушей
        downloadPushArray()
        
        tabBar.layer.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82).cgColor
//        tabBar.tintColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
//        tabBar.tintColor = .clear
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
     
        
        
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
        selectedIndex = 0
        
        loadCatalog()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let userInfo = UserDefaults.standard.object(forKey: "ConsentMe2MePull") as? [AnyHashable : Any] {
                let meToMeReq = RequestMeToMeModel(userInfo: userInfo)
                
                let topvc = UIApplication.topViewController()
                
                let vc = MeToMeRequestController()
                vc.viewModel = meToMeReq
                vc.modalPresentationStyle = .fullScreen
                topvc?.present(vc, animated: true, completion: {
                    UserDefaults.standard.set(nil, forKey: "ConsentMe2MePull")
                })
            }
            
            if let bankId = UserDefaults.standard.object(forKey: "GetMe2MeDebitConsent") as? String {
                let body = ["bankId": bankId] as [String: AnyObject]
                NetworkManager<GetMe2MeDebitConsentDecodableModel>.addRequest(.getMe2MeDebitConsent, [:], body) { model, error in
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        if model.data != nil {
                            DispatchQueue.main.async {
                                let meToMeReq = RequestMeToMeModel(model: model)
                                
                                let topvc = UIApplication.topViewController()
                                
                                let vc = MeToMeRequestController()
                                vc.viewModel = meToMeReq
                                vc.modalPresentationStyle = .fullScreen
                                topvc?.present(vc, animated: true, completion: {
                                    UserDefaults.standard.set(nil, forKey: "GetMe2MeDebitConsent")
                                })
                            }
                        } else {
//                            let meToMeReq = RequestMeToMeModel(model: model)
                            
                            let topvc = UIApplication.topViewController()
                            
                            let vc = MeToMeRequestController()
//                            vc.viewModel = meToMeReq
                            vc.modalPresentationStyle = .fullScreen
                            topvc?.present(vc, animated: true, completion: {
                                UserDefaults.standard.set(nil, forKey: "GetMe2MeDebitConsent")
                            })
                        }
                    }
                }
            }
            
        }
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
        
        
        NetworkHelper.request(.getBankFullInfoList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let banks = model as? [BankFullInfoList] else { return }
            Dict.shared.bankFullInfoList = banks
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
        
        NetworkHelper.request(.getMobileSystem) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let paymentSystem = model as? [MobileList] else { return }
            Dict.shared.mobileSystem = paymentSystem
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

        /// Add REALM
        AddAllUserCardtList.add() {}
        
        
//        NetworkHelper.request(.getProductList) { cardList , error in
//            if error != nil {
//                self.showAlert(with: "Ошибка", and: error!)
//            }
//            guard let cardList = cardList as? [GetProductListDatum] else { return }
//            print("DEBUG: Load card list... Count is: ", cardList.count)
//        }
        
    }
// MARK: Загрузка истории пушей
    
    /// Отправляем запрос на сервер, для получения истории пушей
    private func downloadPushArray() {
        let body = ["offset": "0",
                            "limit" : "100",
                            "notificationType" : "PUSH",
                            "notificationState" : "SENT"
                           ]
        GetNotificationsModelSaved.add(body, [:]) {}
    }


}


