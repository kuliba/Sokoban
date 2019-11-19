//
//  ProductsCoordinator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 19.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class ProductsModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet private weak var carouselViewController: CarouselViewController!

    override func awakeFromNib() {

        let configurator = AuthorizationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: authorizationViewController)
    }

}
