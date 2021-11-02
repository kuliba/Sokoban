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
        router.setRootModule( mainTabBarController, hideBar: true)
    }
    
    override func start() {
    }
}


extension MainTabBarCoordinator: PaymentsViewControllerDelegate {
    
    func selectTransition(_ controller: UIViewController) {
        let navigationController = UINavigationController()
        let newRouter = Router(navigationController: navigationController)
        let mobilePay = MobilePayCoordinator(router: newRouter)
        addChild(mobilePay)
        mobilePay.start()
        router.present(mobilePay, animated: true)
    }
    
    func goToCountryPayments() {
        let navigationController = UINavigationController()
        let newRouter = Router(navigationController: navigationController)
        let сountryPay = CountryPayCoordinator(router: newRouter)
        addChild(сountryPay)
        сountryPay.start()
        router.setRootModule(сountryPay, hideBar: false) // present(mobilePay, animated: true)
    }
}
