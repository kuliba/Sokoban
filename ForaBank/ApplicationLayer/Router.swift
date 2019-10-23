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
    guard let viewController = mainStoryboard.instantiateInitialViewController() else { return }
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
    guard let paymentsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsViewController") as? PaymentsViewController else {
        return
    }

    paymentsVC.altTableViewDataSource = paymentsTableVC
    paymentsVC.altTableViewDelegate = paymentsTableVC
    topMostVC()?.present(paymentsVC, animated: true)
}
