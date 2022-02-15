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

        @Published var title: String = "Придумайте код"
        var pincode: CurrentValueSubject<String, Never>
        @Published var dots: [DotViewModel]
        @Published var state: State
        
        private let pincodeLength: Int
        
        init(title: String, pincodeLength: Int, pincode: String = "", state: State = .editing) {
            
            self.title = title
            self.pincode = .init(pincode)
            self.dots = Self.dots(pincode: pincode, length: pincodeLength)
            self.state = state
            self.pincodeLength = pincodeLength
        }
        
        static func dots(pincode: String, length: Int) -> [DotViewModel] {
            
            return (0..<length).map{ pincode.count > $0 ? .filled : .empty }
        }
        
        enum State {

            case editing
            case incorrect
            case correct
        }
        
        enum DotViewModel {
            
            case empty
            case filled
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
