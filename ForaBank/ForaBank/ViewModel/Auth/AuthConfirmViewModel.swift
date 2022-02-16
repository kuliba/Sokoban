//
//  AuthConfirmViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 09.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthConfirmViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarViewModel
    var code: CodeViewModel
    @Published var info: InfoViewModel?

    private let model: Model
    
    init(navigationBar: NavigationBarViewModel, code: CodeViewModel, info: InfoViewModel?, model: Model = .emptyMock) {
        
        self.navigationBar = navigationBar
        self.code = code
        self.info = info
        self.model = model
    }
    
    init(_ model: Model, confirmCodeLength: Int, phoneNumber: String, repeatTimeInterval: TimeInterval, dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.navigationBar = NavigationBarViewModel(action: dismissAction)
        self.code = CodeViewModel(title: "Введите код из сообщения", lenght: confirmCodeLength, state: .edit)
        self.info = InfoViewModel(phoneNumber: phoneNumber, repeatTimeInterval: repeatTimeInterval)
    }
}

extension AuthConfirmViewModel {
    
    struct NavigationBarViewModel {
        
        let title = "Вход"
        let backButton: BackButtonViewModel
        
        struct BackButtonViewModel {
            let icon = Image("back_button")
            let action: () -> Void
        }
        
        init(action: @escaping () -> Void) {
            
            self.backButton = BackButtonViewModel(action: action)
        }
    }
    
    class CodeViewModel: ObservableObject {

        var title: String
        var codeLenght: Int
        @Published var code: [String?]
        @Published var textFieldCode: String
        @Published var showKeyboard: Bool
        @Published var state: State
        private var bindings = Set<AnyCancellable>()

        enum State {
            
            case edit
            case check
        }

        internal init(title: String, codeLenght: Int, code: [String?], textFieldCode: String, showKeyboard: Bool, state: State) {
            self.title = title
            self.codeLenght = codeLenght
            self.code = code
            self.textFieldCode = textFieldCode
            self.showKeyboard = showKeyboard
            self.state = state
            bind()
        }
        
        init(title: String, lenght: Int, state: State) {

            self.title = title
            showKeyboard = true
            codeLenght = lenght
            textFieldCode = ""
            self.state = state
            code = []
            code = setupCode(codeLenght: codeLenght)
            bind()
        }

        func bind() {

            $textFieldCode
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] textFieldCode in

                    guard state == .edit else { return }
                    
                    let codeDigits = extractDigits(value: textFieldCode)

                    code = convertDigitsToCode(code: code, value: codeDigits)

                    if codeDigits.count == codeLenght {
                        state = .check
                    }
                }.store(in: &bindings)

            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    switch state {
                    case .edit:
                        code = setupCode(codeLenght: codeLenght)
                        textFieldCode = ""
                        showKeyboard = true
                    case .check:
                        ///TextFieldCode - проверка
                        showKeyboard = false
                        break
                    }
                }.store(in: &bindings)
        }
        
        func setupCode(codeLenght: Int) -> [String?] {

            var code = [String?]()
            for _ in 0..<codeLenght {
                code.append(nil)
            }
            return code
        }

        func extractDigits(value: String) -> [String] {

            value.digits.map({String($0)})
        }

        func convertDigitsToCode(code: [String?], value: [String]) -> [String?] {

            var convertedCode = code
            
            for index in 0..<value.count {
                convertedCode[index] = value[index]
            }
            return convertedCode
        }
    }
    
    class InfoViewModel: ObservableObject {
        
        var title: String
        @Published var subtitle: String?
        @Published var state: State
        
        init(title: String, subtitle: String? = nil, state: State) {
            
            self.title = title
            self.subtitle = subtitle
            self.state = state
        }
        
        init(phoneNumber: String, repeatTimeInterval: TimeInterval) {
            
            //TODO: implement timer
            self.title = "Код отправлен на " + phoneNumber
            self.subtitle = nil
            self.state = .timer(.init(value: "0.35"))
        }
        
        enum State {
            
            case timer(TimerViewModel)
            case button(RepeatButtonViewModel)
        }
        
        struct TimerViewModel {
            
            let value: String
        }
        
        struct RepeatButtonViewModel {
            
            let title = "Отправить повторно"
            let action: () -> Void
        }
    }
}

enum AuthConfirmViewModelAction {
    
    struct Dismiss: Action {}
    struct SendAgain: Action {}
    struct ConfirmCode: Action {
        
        let code: String
    }
}

//MARK: - Samples

extension AuthConfirmViewModel {
    
    static let sampleConfirm: AuthConfirmViewModel = {
        
        let codeViewModel = CodeViewModel(title: "Введите код из сообщения", lenght: 6, state: .edit)
        let infoViewModel = InfoViewModel(title: "+7 ... ... 54 13", subtitle: nil, state: .timer(.init(value: "00:59")))
        let viewModel = AuthConfirmViewModel(navigationBar: .init(action: {}), code: codeViewModel, info: infoViewModel)
        
        return viewModel
    }()
}
