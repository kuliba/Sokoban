//
//  PhoneNumberViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 26.07.2022.
//

import UIKit

class PhoneNumberViewModel {
    
    var title: String
    var image: UIImage?
    var text: String {
        didSet {
            validate(text: text)
        }
    }
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

    init(title: String = "", text: String = "", image: UIImage = UIImage(), type: FieldType = FieldType.text, needValidate: Bool = false, errorText: String = "", isEditable: Bool = true, showChooseButton: Bool = false) {
        
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
            showCurrencyButton = true
            
        case .credidCard:
            needValidate = false
            showChooseButton = true
            showBottomLabel = true
            
        default:
            
            showCurrencyButton = false
        }
    }
    
    private func validate(text: String) {
        if needValidate {
            if text.isEmpty {
//                isError = true
            }
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
        case description
        
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
