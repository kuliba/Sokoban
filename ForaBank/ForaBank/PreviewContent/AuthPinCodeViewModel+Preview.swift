//
//  AuthPinCodeViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation

extension AuthPinCodeViewModel {
    
    static let sample: AuthPinCodeViewModel = {
        
        let pinCode = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4)
        let numpad = AuthPinCodeViewModel.NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .icon(.ic40Delete), action: .delete))
        
        let footer = AuthPinCodeViewModel.FooterViewModel(continueButton: .init(title: "Продолжить",
                                                                   action: {}),
                                             cancelButton: .init(title: "Отменить",
                                                                 action: {}))
        
        return AuthPinCodeViewModel(pinCode: pinCode, numpad: numpad, footer: footer)
    }()
}


extension AuthPinCodeViewModel.PinCodeViewModel {
    
    static let empty = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4)
    
    static let editing = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4, pincode: "12")
    
    static let correct = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4, pincode: "1234", state: .correct)
    
    static let incorrect = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4, pincode: "1234", state: .incorrect)
}
