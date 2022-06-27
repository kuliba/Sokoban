//
//  AuthPinCodeViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation
import SwiftUI

extension AuthPinCodeViewModel {
    
    static let sample: AuthPinCodeViewModel = {
        
        let pinCode = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4)
        let numpad = AuthPinCodeViewModel.NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .icon(.ic40Delete), action: .delete))
        
        let footer = AuthPinCodeViewModel.FooterViewModel(continueButton: .init(title: "Продолжить",
                                                                   action: {}),
                                             cancelButton: .init(title: "Отменить",
                                                                 action: {}))
        
        return AuthPinCodeViewModel(pincodeValue: .init(""), pinCode: pinCode, numpad: numpad, footer: footer, dismissAction: {})
    }()
}


extension AuthPinCodeViewModel.PinCodeViewModel {
    
    static let empty = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeLength: 4)
    
    static let editing = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeValue: "12", pincodeLength: 4)
    
    static let correct = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeValue: "1234", pincodeLength: 4, style: .correct)
    
    static let incorrect = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeValue: "1234", pincodeLength: 4, style: .incorrect)
    
    static let correctAnimating: AuthPinCodeViewModel.PinCodeViewModel = {
        
        let viewModel = AuthPinCodeViewModel.PinCodeViewModel(title: "Придумайте код", pincodeValue: "1234", pincodeLength: 4, style: .correct)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            withAnimation {
                viewModel.isAnimated = true
            }
        }
        
        return viewModel
    }()
}
