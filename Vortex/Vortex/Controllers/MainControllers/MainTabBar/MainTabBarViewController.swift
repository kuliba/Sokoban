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
        getFastPaymentContractList()
        tabBar.layer.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82).cgColor
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.7).cgColor
        tabBar.clipsToBounds = true
        
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
        loadCatalog()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil {
            let controller = InternetTVMainController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
            return
        }

    //GlobalModule.c2bURL = "success"
//        GlobalModule.c2bURL = "https://medium.com/wolox/ios-deep-linking-url-scheme-vs-universal-links-50abd3802f97"
        //GlobalModule.c2bURL = "https://qr.nspk.ru/AS1000592TVC2NHL8U7OG5A3VG0P6FEV?type=01&bank=100000000217&sum=1000701&cur=RUB&crc=65AC"
        
        //GlobalModule.c2bURL = "https://qr.nspk.ru/AD10000OMU7T96VL9O3RJOMIC49IKSJV?type=02&bank=100000000007&sum=16100&cur=RUB&crc=7025"
        
        if GlobalModule.c2bURL != nil {
            let controller = C2BDetailsViewController.storyboardInstance()!
            controller.getUImage = { self.mainVC.model.images.value[$0]?.uiImage }
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UITabBar.appearance().tintColor = .black
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
            
            if UserDefaults.standard.object(forKey: "AnyPull") is [AnyHashable : Any] {
                let topvc = UIApplication.topViewController()
                
                let pushHistory = PushHistoryViewController.storyboardInstance()!
                let nc = UINavigationController(rootViewController: pushHistory)
                nc.modalPresentationStyle = .fullScreen
                topvc?.present(nc, animated: true, completion: {
                    UserDefaults.standard.set(nil, forKey: "AnyPull")
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
                    
                            let topvc = UIApplication.topViewController()
                            let vc = MeToMeRequestController()
                    
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
        
        /*
        if (GlobalModule.c2bURL == nil) {
            AppUpdater.shared.showUpdate(withConfirmation: true)
        }
         */
        
        NetworkHelper.request(.getCountries) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let countries = model as? [CountriesList] else { return }
            Dict.shared.countries = countries
        }
        
        NetworkHelper.request(.getBanks) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let banks = model as? [BanksList] else { return }
            Dict.shared.banks = banks
        }
        
        
        NetworkHelper.request(.getBankFullInfoList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let banks = model as? [BankFullInfoList] else { return }
            Dict.shared.bankFullInfoList = banks
        }
        
        NetworkHelper.request(.getPaymentSystemList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let paymentSystem = model as? [PaymentSystemList] else { return }
            Dict.shared.paymentList = paymentSystem
        }
        
        NetworkHelper.request(.getMobileSystem) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let paymentSystem = model as? [MobileList] else { return }
            Dict.shared.mobileSystem = paymentSystem
        }
        
        NetworkHelper.request(.getCurrencyList) { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
            guard let currencySystem = model as? [CurrencyList] else { return }
            Dict.shared.currencyList = currencySystem
        }
    }
    
    func getFastPaymentContractList() {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                
            }
            guard let model = model else { return }
            
            let a = model.data?.first
            let b = a?.fastPaymentContractAttributeList?.first?.phoneNumber ?? ""
            let clientID = a?.fastPaymentContractAttributeList?.first?.clientID ?? 0
            
            if model.statusCode == 0 {
                UserDefaults.standard.set(b, forKey: "UserPhone")
                UserDefaults.standard.set(clientID, forKey: "clientId")
            } else {
                
            }
        }
    }
}


