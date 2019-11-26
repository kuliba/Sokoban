//
//  PaymentProcessCoordinator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IPaymentProcessHandler {
    var canAskFee: Bool { get }
    var canMakePayment: Bool { get }
}

protocol PaymentProcessHandlerDelegate {
    func didChangedDestination(<#parameters#>) -> <#return type#> {
    <#function body#>
    }
}

class PaymentProcessHandler: IPaymentProcessHandler {

}
