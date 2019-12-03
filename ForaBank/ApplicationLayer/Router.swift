//
//  Router.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

//MARK: - Zones

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

//MARK: - Sharing

func showShareScreen(textToShare shareText: String) {
    let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
    topMostVC()?.present(activityController, animated: true, completion: nil)
}

//MARK: - Payment

func showPaymentViewController() {
    guard let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
        return
    }
    topMostVC()?.present(paymentVC, animated: true)
}

func showPaymentsTableViewController() {
    guard let paymentsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsTableViewController") as? PaymentsTableViewController else {
        return
    }

    topMostVC()?.present(paymentsVC, animated: true)
}

//MARK: - Scan

func showScanCardController(delegate: CardIOPaymentViewControllerDelegate) {

    guard let cardScanVC = CardIOPaymentViewController(paymentDelegate: delegate, scanningEnabled: true) else { return }
    
    cardScanVC.modalPresentationStyle = .fullScreen
    cardScanVC.collectCVV = false
    cardScanVC.collectExpiry = false
    cardScanVC.guideColor = UIColor(red: 0.13, green: 0.54, blue: 0.61, alpha: 1.00)
    cardScanVC.hideCardIOLogo = true
    
    topMostVC()?.present(cardScanVC, animated: true, completion: nil)
}
