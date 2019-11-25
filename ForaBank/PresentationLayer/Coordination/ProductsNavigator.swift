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
        static let productListSegue = "toProductList"
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
            rootViewController?.performSegue(withIdentifier: SegueIdentifier.productListSegue, sender: nil)
            break
        }
    }
}
