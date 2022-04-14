//
//  ForaInputModel.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

/// Модель для управлением ForaInputView.
class C2BDetailsInputViewModel {
    var title: String
    var image: UIImage?
    var text: String
    var bottomLabel = ""
    var fieldType: FieldType!
    var isError: Bool = false
    var errorText: String?
    var needValidate: Bool
    var needCleanButton: Bool = false
    var showChooseButton: Bool
    var showCurrencyButton = false
    var showBottomLabel = false
    var isEditable: Bool
    var activeCurrency: ButtonСurrency?
    var cardModel: GetProductListDatum?

    init(title: String, text: String = "", image: UIImage? = UIImage(), type: FieldType = FieldType.text, needValidate: Bool = false, errorText: String = "", isEditable: Bool = true, showChooseButton: Bool = false) {

        self.isEditable = isEditable
        self.needValidate = isEditable
        self.title = title
        self.text = text
        self.image = image
        self.fieldType = type
        self.needValidate = needValidate
        self.errorText = errorText
        self.showChooseButton = showChooseButton
        configButton()
    }

    private func configButton() {
        switch fieldType.self {
        case .amountOfTransfer:
            needValidate = false
            activeCurrency = ButtonСurrency.RUB
            showCurrencyButton = true

        case .credidCard:
            needValidate = false
            showChooseButton = true
            showBottomLabel = true

        default:
            showCurrencyButton = false
        }
    }

    enum FieldType {
        case text
        case phone
        case details
        case mail
        case number
        case amountOfTransfer
        case credidCard
        case smsCode

        var keyboardType: UIKeyboardType {
            switch self {
            case .phone:
                return UIKeyboardType.phonePad
            case .mail:
                return UIKeyboardType.emailAddress
            case .number, .smsCode:
                return UIKeyboardType.numberPad
            case .amountOfTransfer:
                return UIKeyboardType.decimalPad
            default:
                return UIKeyboardType.default
            }
        }
    }
}

