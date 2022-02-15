//
//  AuthPinCodeViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Foundation

extension AuthPinCodeViewModel {
    
    static let sample: AuthPinCodeViewModel = {
        
        let pinCode = AuthPinCodeViewModel.PinCodeViewModel()
        let numpad = AuthPinCodeViewModel.NumPadViewModel(buttons: [[.init(type: .digit("1"), action: {_ in }),
                                                               .init(type: .digit("2"), action: {_ in }),
                                                               .init(type: .digit("3"), action: {_ in })],
                                            
                                                              [.init(type: .digit("4"), action: {_ in }),
                                                               .init(type: .digit("5"), action: {_ in }),
                                                               .init(type: .digit("6"), action: {_ in })],

                                                              [.init(type: .digit("7"), action: {_ in }),
                                                               .init(type: .digit("8"), action: {_ in }),
                                                               .init(type: .digit("9"), action: {_ in })],
                                            
                                                              [.init(type: .text("Выход"), action: {_ in }),
                                                               .init(type: .digit("0"), action: {_ in }),
                                                               .init(type: .icon(.ic40Delete), action: {_ in })]])
        
        let footer = AuthPinCodeViewModel.FooterViewModel(continueButton: .init(title: "Продолжить",
                                                                   action: {}),
                                             cancelButton: .init(title: "Отменить",
                                                                 action: {}))
        
        return AuthPinCodeViewModel(pinCode: pinCode, numpad: numpad, footer: footer)
    }()
}
