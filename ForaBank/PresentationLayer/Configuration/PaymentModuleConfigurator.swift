//
//  PaymentModuleConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 27.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PaymentModuleConfigurator {

    func configureModuleForView<UIViewController>(view: UIViewController) {

        if let viewController = view as? PaymentsDetailsViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: PaymentsDetailsViewController) {
        let presenter = PaymentDetailsPresenter(delegate: viewController)
        viewController.presenter = presenter
        viewController.delegate = presenter
    }
}
