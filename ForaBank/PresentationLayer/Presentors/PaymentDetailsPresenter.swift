//
//  PaymentDetailsPresenter.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum PaymentOptionType {
    case option(PaymentOption)
    case cardNumber(String)
    case accountNumber(String)
    case phoneNumber(String)
}

protocol IPaymentDetailsPresenter: class {
    var delegate: PaymentDetailsPresenterDelegate? { get }
}

protocol PaymentDetailsPresenterDelegate: class {
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool)
    func didFinishPreparation(success: Bool)
}

class PaymentDetailsPresenter: IPaymentDetailsPresenter {
    weak var delegate: PaymentDetailsPresenterDelegate?

    private var sourcePaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var destinaionPaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var amount: Double? {
        didSet {
            onSomeValueUpdated()
        }
    }

    private var isLoading = false
    private var canAskFee = false
    private var canMakePayment = false

    init(delegate: PaymentDetailsPresenterDelegate) {
        self.delegate = delegate
    }
}

extension PaymentDetailsPresenter {

    private func onSomeValueUpdated() {
        guard let destination = destinaionPaymentOption, let source = sourcePaymentOption else {
            return
        }

        let isValidDestination = isValid(paymentOption: destination)
        let isValidSource = isValid(paymentOption: source)

        let canStartWithOptions = isValidSource && isValidDestination && amount != nil
        canAskFee = canStartWithOptions

        delegate?.didUpdate(isLoading: isLoading, canAskFee: canAskFee, canMakePayment: canMakePayment)
    }

    private func isValid(paymentOption: PaymentOptionType) -> Bool {
        switch paymentOption {
        case .option(_):
            return true
        case .accountNumber(let accountNumber):
            return accountNumber.count == 20
        case .cardNumber(let cardNumber):
            return cardNumber.count == 16
        case .phoneNumber(let phoneNumber):
            return phoneNumber.count == 11
        }
    }
}

extension PaymentDetailsPresenter: PaymentsDetailsViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType) {
        print(paymentOption)
        sourcePaymentOption = paymentOption
    }

    func didChangeDestination(paymentOption: PaymentOptionType) {
        print(paymentOption)
        destinaionPaymentOption = paymentOption
    }

    func didChangeAmount(amount: Double?) {
        self.amount = amount
    }

    func didPressPrepareButton() {
        preparePayment()
    }

    func didPressPaymentButton() {

    }
}

private extension PaymentDetailsPresenter {
    func preparePayment() {

        guard let amount = self.amount else {
            return
        }
        delegate?.didUpdate(isLoading: true, canAskFee: canAskFee, canMakePayment: canMakePayment)

        let completion: (Bool, String?) -> Void = { [weak self] (success, token) in
            guard let canAskFee = self?.canAskFee, let canMakePayment = self?.canMakePayment else {
                return
            }
            self?.delegate?.didUpdate(isLoading: false, canAskFee: canAskFee, canMakePayment: canMakePayment)
            self?.delegate?.didFinishPreparation(success: success)
        }

        switch (sourcePaymentOption, destinaionPaymentOption) {
        case (.option(let sourceOption), .option(let destinationOption)):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: destinationOption.number, amount: amount, completionHandler: completion)
            break
        case (.option(let sourceOption), .phoneNumber(let phoneNumber)):
            NetworkManager.shared().prepareCard2Phone(from: sourceOption.number, to: phoneNumber, amount: amount, completionHandler: completion)
            break
        case (.option(let sourceOption), .cardNumber(let stringNumber)), (.option(let sourceOption), .accountNumber(let stringNumber)):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: stringNumber, amount: amount, completionHandler: completion)
            break
        default:
            break
        }
    }
}
