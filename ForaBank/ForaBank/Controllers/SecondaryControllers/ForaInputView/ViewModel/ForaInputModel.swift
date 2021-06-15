//
//  ForaInputModel.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

/// Модель для управлением ForaInputView.
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
    
    /// Инициализирует `ForaInputModel` заданными данными
    ///
    /// - Parameters:
    ///   - title: Обязательный параметр, это Имя в `Placeholder`.
    ///   - text: Текст записывается в `TextField`, по умолчанию пустой
    ///   - image: Не обязательный параметр, Иконка слева от `TextField`
    ///   - type: Обязательный параметр, он конфигуриует View в зависимости от типа `FieldType`
    ///   - needValidate: Не обязательный параметр,  указывает на то, будет ли TextField обрабатывать ошибки ввода. По умолчанию `false`
    ///   - errorText: Не обязательный параметр, Текст выводимой ошибки
    ///   - isEditable: Не обязательный параметр, указывает будет ли поле редактируемым. По умолчанию `true`
    ///   - showChooseButton: Не обязательный параметр, указывает будет ли отображаться иконка выбора, и по нажатию на view вызывается тот же метод. По умолчанию `false`
    init(title: String, text: String = "", image: UIImage = UIImage(), type: FieldType = FieldType.text, needValidate: Bool = false, errorText: String = "", isEditable: Bool = true, showChooseButton: Bool = false) {
        
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
        case smsCode
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .phone:
                return UIKeyboardType.phonePad
            case .mail:
                return UIKeyboardType.emailAddress
            case .number, .amountOfTransfer, .smsCode:
                return UIKeyboardType.numberPad
            default:
                return UIKeyboardType.default
            }
        }
    }
    
    
}

enum ButtonСurrency {
    case USD
    case RUB
}
