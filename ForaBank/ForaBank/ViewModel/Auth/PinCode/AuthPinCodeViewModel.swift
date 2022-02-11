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
    
    var pinCode: PinCodeViewModel
    @Published var numpad: [[ButtonViewModel?]]
    @Published var bottomButton: FooterViewModel

    init() {

        pinCode = PinCodeViewModel()
        numpad = [[nil]]
        bottomButton = FooterViewModel(continueButton: .init(title: "Продолжить",
                                                                   action: {}),
                                             cancelButton: .init(title: "Отменить",
                                                                 action: {}))

        numpad = [[.init(type: .digit("1"), action: {_ in }),
                   .init(type: .digit("2"), action: {_ in }),
                   .init(type: .digit("3"), action: {_ in })],
    
                  [.init(type: .digit("4"), action: {_ in }),
                   .init(type: .digit("5"), action: {_ in }),
                   .init(type: .digit("6"), action: {_ in })],

                  [.init(type: .digit("7"), action: {_ in }),
                   .init(type: .digit("8"), action: {_ in }),
                   .init(type: .digit("8"), action: {_ in })],

                  [.init(type: .text("Выход"), action: {_ in }),
                   .init(type: .digit("0"), action: {_ in }),
                   .init(type: .icon(.ic40Delete), action: {_ in })]]
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

    struct ButtonViewModel: Identifiable {

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
