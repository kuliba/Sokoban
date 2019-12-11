//
//  IPaymentDetailsPresenter.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol PaymentDetailsPresenterDelegate: class {
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool)
    func didFinishPreparation(success: Bool)
}

protocol IPaymentDetailsPresenter: class {
    var delegate: PaymentDetailsPresenterDelegate? { get }
}
