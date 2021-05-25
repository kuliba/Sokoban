//
//  PaymentModuleInitializer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 27.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PaymentModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet private weak var paymentsDetailsViewController: PaymentsDetailsViewController!

    override func awakeFromNib() {
        let configurator = PaymentModuleConfigurator()
        configurator.configureModuleForView(view: paymentsDetailsViewController)
    }

}
class PaymentModuleInitializer1: NSObject {

    //Connect with object on storyboard
    @IBOutlet private weak var paymentsDetailsViewController: SBPViewController!

    override func awakeFromNib() {
        let configurator = PaymentModuleConfigurator()
        configurator.configureModuleForView(view: paymentsDetailsViewController)
    }

}
