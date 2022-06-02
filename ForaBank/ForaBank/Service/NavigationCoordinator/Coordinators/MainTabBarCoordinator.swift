//
//  MainTabBarCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import UIKit

class MainTabBarCoordinator: Coordinator {

    let mainTabBarController = MainTabBarViewController()

    override init(router: RouterType) {
        super.init(router: router)
        router.push(mainTabBarController, animated: true, completion: nil)
        mainTabBarController.paymentsVC.delegate = self
        mainTabBarController.mainVC.delegate = self
    }
    
    deinit {
        print("Deinit main coordinator")
    }
    
    override func start() {
    }

}

extension MainTabBarCoordinator: MainViewControllerDelegate {
    
    
    func goPaymentsViewController() {
        let settingCoordinator = PaymentsViewCoordinator(router: router)
        addChild(settingCoordinator)
        settingCoordinator.start()
        router.present(settingCoordinator, animated: true)
    }
    
    
    func goProductViewController(product: UserAllCardsModel, products: [UserAllCardsModel]) {
        let productCoordinator = ProductCoordinator(router: router)
        productCoordinator.productViewController.product = product
        productCoordinator.productViewController.products = products
        productCoordinator.start()
        router.present(productCoordinator, animated: true)
    }
    
    func goSettingViewController() {
        let settingCoordinator = SettingViewCoordinator(router: router)
        addChild(settingCoordinator)
        settingCoordinator.start()
        router.present(settingCoordinator, animated: true)
    }
    
}



extension MainTabBarCoordinator: PaymentsViewControllerDelegate {
    
//    func goToGKHController() {
//        let gkhCoordinator = GKHCoordinator(router: router)
//        addChild(gkhCoordinator)
//        gkhCoordinator.start()
// //       router.present(gkhCoordinator, animated: true)
//        router.push(gkhCoordinator.toPresentable(), animated: true) {
//            [weak self, weak gkhCoordinator] in
//                self?.removeChild(gkhCoordinator)
//        }
//    }
    
    
//    func goToQRController() {
//        let qrCoordinator = QRCoordinator(router: router)
//        addChild(qrCoordinator)
//        qrCoordinator.start()
//        router.setRootModule(qrCoordinator, hideBar: false)
//        router.push(qrCoordinator.toPresentable(), animated: true) {
//            [weak self, weak qrCoordinator] in
//                self?.removeChild(qrCoordinator)
//        }
//    }
    
    func toMobilePay(_ controller: UIViewController, _ phone: String) {
        let mobilePay = MobilePayCoordinator(router: router)
        addChild(mobilePay)
        mobilePay.start()
        
        router.present(mobilePay, animated: true)
    }
    
    func goToCountryPayments() {
        let сountryPay = CountryPayCoordinator(router: router)
        addChild(сountryPay)
        сountryPay.start()
        router.present(сountryPay, animated: true)
    }
    
    func goToPaymentByPhone() {
        let сountryPay = PaymentByPhoneCoordiantor(router: router)
        addChild(сountryPay)
        сountryPay.start()
        router.present(сountryPay, animated: true)
    }
    
}

