//
//  PaymentRequestHandler.swift
//  ForaBank
//
//  Created by MacAdmin on 14.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PaymentRequestHandler {
    
    var amount: Double?
    var completion: ((Bool, String?) -> Void)?
    
    init(amount: Double, completion: @escaping (Bool, String?) -> Void) {
        self.amount = amount
        self.completion = completion
    }
    
    func preparePayment(sourcePaymentOption: PaymentOptionType, destinaionPaymentOption: PaymentOptionType) {
        
        switch (sourcePaymentOption, destinaionPaymentOption) {
        case (.option(let sourceOption), .option(let destinationOption)):
            processOptionToOption(sourceOption: sourceOption, destinationOption: destinationOption)
            break
        case (.option(let sourceOption), .phoneNumber(_)):
            processOptionToPhone(sourceOption: sourceOption, destinationOption: destinaionPaymentOption)
            break
        case (.option(let sourceOption), .cardNumber(_)), (.option(let sourceOption), .accountNumber(_)):
            processOptionToNumber(sourceOption: sourceOption, destinationOption: destinaionPaymentOption)
            break
        default:
            break
        }
    }
    
    private func processOptionToOption(sourceOption: PaymentOption, destinationOption: PaymentOption) {
        
        guard let nonNilAmount = amount, let nonNilCompletion = completion else {
            return
        }
        switch (sourceOption.productType, destinationOption.type) {
        case (.card, .card):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: destinationOption.number, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.card, .safeDeposit):
            NetworkManager.shared().prepareCard2Account(from: sourceOption.number, to: destinationOption.number, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.account, .safeDeposit):
            NetworkManager.shared().prepareAccount2Account(from: sourceOption.number, to: destinationOption.number, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.account, .card):
            NetworkManager.shared().prepareAccount2Card(from: sourceOption.number, to: destinationOption.number, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        default:
            break
        }
    }
    
    private func processOptionToPhone(sourceOption: PaymentOption, destinationOption: PaymentOptionType) {
        
        guard let nonNilAmount = amount, let nonNilCompletion = completion else {
            return
        }
        switch (sourceOption.productType, destinationOption) {
        case (.card, .phoneNumber(let phoneNumber)):
            NetworkManager.shared().prepareCard2Phone(from: sourceOption.number, to: phoneNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.account, .phoneNumber(let phoneNumber)):
            NetworkManager.shared().prepareAccount2Phone(from: sourceOption.number, to: phoneNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        default:
            break
        }
    }
    
    private func processOptionToNumber(sourceOption: PaymentOption, destinationOption: PaymentOptionType) {
        
        guard let nonNilAmount = amount, let nonNilCompletion = completion else {
            return
        }
        switch (sourceOption.productType, destinationOption) {
        case (.card, .cardNumber(let stringNumber)):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: stringNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.card, .accountNumber(let stringNumber)):
            NetworkManager.shared().prepareCard2Account(from: sourceOption.number, to: stringNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.account, .accountNumber(let stringNumber)):
            NetworkManager.shared().prepareAccount2Account(from: sourceOption.number, to: stringNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
            break
        case (.account, .cardNumber(let stringNumber)):
            NetworkManager.shared().prepareAccount2Card(from: sourceOption.number, to: stringNumber, amount: nonNilAmount, completionHandler: nonNilCompletion)
        break
        default:
            break
        }
    }
}
