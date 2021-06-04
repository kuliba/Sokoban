//
//  ForaInputModel.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ForaInputModel {
    let title: String
    let image: UIImage
    var text: String {
        didSet {
//            guard let text = self.text else { return }
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
    var activeCurrency: ButtonСurrency? 
    
    init(title: String, text: String = "" ,image: UIImage = UIImage(), type: FieldType = FieldType.text, needValidate: Bool = false, errorText: String = "", isEditable: Bool = true, showChooseButton: Bool = false) {
        
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
            
//            showChooseButton = false
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
        case mail
        case number
        case amountOfTransfer
        case credidCard
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .text:
                return UIKeyboardType.default
            case .phone:
                return UIKeyboardType.phonePad
            case .mail:
                return UIKeyboardType.emailAddress
            case .number:
                return UIKeyboardType.numberPad
            case .amountOfTransfer:
                return UIKeyboardType.numberPad
            case .credidCard:
                return UIKeyboardType.default
            }
        }
    }
    
    
}

enum ButtonСurrency {
    case USD
    case RUB
}
