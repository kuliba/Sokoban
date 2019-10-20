//
//  Router.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

func setupUnauthorizedZone() {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "UnauthorizedZone", bundle: nil)
    let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: UnauthorizedZoneTabBarController.self)
    ) as! UnauthorizedZoneTabBarController
    setRootVC(newRootVC: viewController)
}

func setupAuthorizedZone() {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "AuthorizedZone", bundle: nil)
    let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: TabBarController.self)
    ) as! TabBarController
    setRootVC(newRootVC: viewController)
}

func showPaymentViewController() {
    guard let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
        return
    }
    topMostVC()?.present(paymentVC, animated: true)
}

func showPaymentsTableViewController() {
    let paymentsTableVC = PaymentsTableViewController()
    let navigationVC = UINavigationController(rootViewController: paymentsTableVC)
    topMostVC()?.present(navigationVC, animated: true)
}
