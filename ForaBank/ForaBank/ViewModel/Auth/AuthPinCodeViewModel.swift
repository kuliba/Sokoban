//
//  AuthPinCodeViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 10.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthPinCodeViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()
    
    let pinCode: PinCodeViewModel
    @Published var numpad: NumPadViewModel
    @Published var footer: FooterViewModel

    init(pinCode: PinCodeViewModel, numpad: NumPadViewModel, footer: FooterViewModel) {
        
        self.pinCode = pinCode
        self.numpad = numpad
        self.footer = footer
    }
}

extension AuthPinCodeViewModel {
    
    class PinCodeViewModel: ObservableObject {

        let title: String = "Придумайте код"
        @Published var code: [String?] = [nil, nil, nil, nil]
        @Published var state: State = .editing
        
        enum State {

            case editing
            case incorrect
            case correct
        }
    }
    
    class NumPadViewModel: ObservableObject {
        
        @Published var buttons: [[ButtonViewModel?]]
        
        init(buttons: [[ButtonViewModel?]]) {
            
            self.buttons = buttons
        }
    }

    struct ButtonViewModel: Identifiable, Hashable {

        static func == (lhs: ButtonViewModel, rhs: ButtonViewModel) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
        }
        
        let id = UUID()
        let type: Kind
        let action: (ButtonViewModel.ID) -> Void
        
        enum Kind {
            
            case digit(String)
            case icon(Image)
            case text(String)
        }
    }

    class FooterViewModel: ObservableObject {
        
        @Published var continueButton: ButtonViewModel?
        @Published var cancelButton: ButtonViewModel?
        
        struct ButtonViewModel {
            
            let title: String
            let action: () -> Void
        }
        
        internal init(continueButton: ButtonViewModel, cancelButton: ButtonViewModel) {

            self.continueButton = continueButton
            self.cancelButton = cancelButton
        }
    }
}

enum AuthPinCodeViewModelAction {

    struct Cancel: Action {}
    struct Continue: Action {

        let code: String
    }
}
