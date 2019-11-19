//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol INavigator {
    associatedtype Destination

    func navigate(to destination: Destination)
}

class ProductsNavigator: INavigator {

    private struct SegueIdentifier {
        static let loginSegue = "loginSegue"
        static let signUp = "ToPasscodeSignUpViewControllerSegue"
        static let activateCard = "ToActivateCardViewControllerSegue"
        static let createPaymentSegue = "createPaymentSegue"
        static let passcodeSignUn = "passcodeSignUp"
        static let thermsAndConditions = "ToThermsViewControllerSegue"
    }

    enum Destination {
        case createProduct
    }

    private weak var rootViewController: UIViewController?

    // MARK: - Initializer

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    // MARK: - Navigator

    public func navigate(to destination: Destination) {

        switch destination {
        case .createProduct:
            rootViewController?.performSegue(withIdentifier: "", sender: nil)
            break
        }
    }
}
