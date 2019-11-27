//
//  PaymentDetailsPresenter.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum PaymentOptionType {
    case phoneNumber
    case cardNumber
    case accountNumber
}

protocol IPaymentDetailsPresenter {
    var delegate: PaymentDetailsPresenterDelegate { get }
}

protocol PaymentDetailsPresenterDelegate {
    func didChangeSource(paymentOption: PaymentOption)
    func didChangeDestination(paymentOption: PaymentOption)

    func didChangeSum(sum: Double)

    func didPressFeeButton()
    func didPressPaymentButton()
}

protocol PaymentProcessHandlerDelegate {
    func didChangeSource(paymentOption: PaymentOption)
    func didChangeDestination(paymentOption: PaymentOption)

    func didChangeSum(sum: Double)

    func didPressFeeButton()
    func didPressPaymentButton()
}

class PaymentDetailsPresenter: IPaymentDetailsPresenter {
    var delegate: PaymentDetailsPresenterDelegate

    var canAskFee = false
    var canMakePayment = false

    private var sourcePaymentOption: PaymentOption?
    private var destinaionPaymentOption: PaymentOption?
    private var sum: Double = 0.0

    init(delegate: PaymentDetailsPresenterDelegate) {
        self.delegate = delegate
    }
}

extension PaymentDetailsPresenter: PaymentProcessHandlerDelegate {
    func didChangeSource(paymentOption: PaymentOption) {
        sourcePaymentOption = paymentOption
    }

    func didChangeDestination(paymentOption: PaymentOption) {
        destinaionPaymentOption = paymentOption
    }

    func didChangeSum(sum: Double) {
        self.sum = sum
    }

    func didPressFeeButton() {

    }

    func didPressPaymentButton() {

    }
}
