//
//  CardNumberCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class CardNumberCellProvider: ICellProvider {
    var currentValue: IPresentationModel?
    
    let iconName = "payments_transfer_between-accounts"
    let textFieldPlaceholder = "Введите номер карты или счёта"
    var isLoading: Bool = false
    
    @objc func reformatAsCardNumber(textField: UITextField) {
//        var targetCursorPosition = 0
//        if let startPosition = textField.selectedTextRange?.start {
//            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
//        }
//
//        var cardNumberWithoutSpaces = ""
//        if let text = textField.text {
//            cardNumberWithoutSpaces = removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
//        }
//
//        if cardNumberWithoutSpaces.count > 19 {
//            textField.text = previousTextFieldContent
//            textField.selectedTextRange = previousSelection
//            return
//        }
//
//        let cardNumberWithSpaces = insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
//        textField.text = cardNumberWithSpaces
//
//        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
//            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
//        }
    }

    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func getAllPaymentOptions() {
        allPaymentOptions { (success, paymentOptions) in
            return paymentOptions
        }
    }
}
