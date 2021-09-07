//
//  MainTabBarViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    var netAlert: NetDetectAlert!
    var netStatus: Bool?
    
    private func netDetect() {
        self.netAlert = NetDetectAlert(self.view)
        if self.netAlert != nil {
            self.view.addSubview(self.netAlert)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [weak self] in
                if NetStatus.shared.isConnected == true {
                    self?.netStatus = true
                    self?.netAlert?.removeFromSuperview()
                } else {
                    self?.netStatus = false
                    self?.netDetect()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.barTintColor = .black
        tabBar.layer.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82).cgColor
        tabBar.tintColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
     
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
        selectedIndex = 0
        
        loadCatalog()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let userInfo = UserDefaults.standard.object(forKey: "ConsentMe2MePull") as? [AnyHashable : Any] else { return }
            let meToMeReq = RequestMeToMeModel(userInfo: userInfo)
            
            let topvc = UIApplication.topViewController()
            
            let vc = MeToMeRequestController()
            vc.viewModel = meToMeReq
            vc.modalPresentationStyle = .fullScreen
            topvc?.present(vc, animated: true, completion: {
                UserDefaults.standard.set(nil, forKey: "ConsentMe2MePull")
            })
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
        
        NetworkHelper.request(.getCurrencyList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let currencySystem = model as? [CurrencyList] else { return }
            Dict.shared.currencyList = currencySystem
            print("DEBUG: Load Currency")
        }
        
        AddAllUserCardtList.add()
        
        
//        NetworkHelper.request(.getProductList) { cardList , error in
//            if error != nil {
//                self.showAlert(with: "Ошибка", and: error!)
//            }
//            guard let cardList = cardList as? [GetProductListDatum] else { return }
//            print("DEBUG: Load card list... Count is: ", cardList.count)
//        }
        
    }

}
