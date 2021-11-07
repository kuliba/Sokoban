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
        router.setRootModule(mainTabBarController, hideBar: true)
        mainTabBarController.paymentsVC.delegate = self
    }
    
    override func start() {
    }
}


extension MainTabBarCoordinator: PaymentsViewControllerDelegate {
    
    func toMobilePay(_ controller: UIViewController) {
//        let navigationController = UINavigationController()
//        let newRouter = Router(navigationController: navigationController)
        let mobilePay = MobilePayCoordinator(router: router)
        addChild(mobilePay)
        mobilePay.start()
//        router.push(mobilePay, animated: true) { [weak self, weak mobilePay] in
//            self?.removeChild(mobilePay)
//        }
        
        router.present(mobilePay, animated: true)
    }
    
    func goToCountryPayments() {
//        let navigationController = UINavigationController()
//        let newRouter = Router(navigationController: navigationController)
        let сountryPay = CountryPayCoordinator(router: router)
        addChild(сountryPay)
        сountryPay.start()
        router.present(сountryPay, animated: true)
    }
}
