//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class ProductsModuleConfigurator {

    func configureModuleForView<UIViewController>(view: UIViewController) {

        if let viewController = view as? CarouselViewController {
            configure(viewController: viewController)
        }
    }

    private func configure(viewController: CarouselViewController) {
        let router = AuthRouter(transitionHandler: viewController)
        viewController.router = router
    }

}
