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
    @Published var isPincodeViewPresented: Bool
    @Published var showingAlert: Bool
    var numberOfPasswordAttempts: Int
    var pincodeViewModel: AuthPinCodeViewModel?

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarViewModel, code: CodeViewModel, info: InfoViewModel?, isPincodeViewPresented: Bool = false, model: Model = .emptyMock, showingAlert: Bool = false, numberOfPasswordAttempts: Int) {
        
        self.navigationBar = navigationBar
        self.code = code
        self.info = info
        self.isPincodeViewPresented = isPincodeViewPresented
        self.model = model
        self.showingAlert = showingAlert
        self.numberOfPasswordAttempts = numberOfPasswordAttempts
    }
    
    init(_ model: Model, confirmCodeLength: Int, phoneNumber: String, repeatTimeInterval: TimeInterval, dismissAction: @escaping () -> Void, numberOfPasswordAttempts: Int) {
        
        self.model = model
        self.navigationBar = NavigationBarViewModel(action: dismissAction)
        self.code = CodeViewModel(title: "Введите код из сообщения", lenght: confirmCodeLength, state: .openening)
        self.info = InfoViewModel(phoneNumber: phoneNumber, repeatTimeInterval: repeatTimeInterval)
        self.isPincodeViewPresented = false
        self.showingAlert = false
        self.numberOfPasswordAttempts = numberOfPasswordAttempts
        
        bind()
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.VerificationCode.Confirm.Response:
                    switch payload {
                    case .correct:
                        code.state = .check
                        pincodeViewModel = AuthPinCodeViewModel(model, mode: .create(step: .one))
                        isPincodeViewPresented = true
                        
                    case .incorrect:
                        showingAlert = true
                        
                    case .error(let error):
                        //TODO: handle error
                        print(error.localizedDescription)
                    }
    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as AuthConfirmViewModelAction.ViewDidAppear:
                    //TODO: after delay switch dtate to edit
                    code.state = .edit
    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        code.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .check:
                    code.showKeyboard = false
                    model.action.send(ModelAction.Auth.VerificationCode.Confirm.Request(code: code.textFieldCode))
                    
                case .edit:
                    code.code = code.setupCode(codeLenght: code.codeLenght)
                    code.textFieldCode = ""
                    code.showKeyboard = true
                
                case .openening:
                    code.showKeyboard = false
                }
                
            }.store(in: &bindings)
        
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
            
            case openening
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

            var convertedCode = setupCode(codeLenght: codeLenght)
            
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
        private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private var bindings = Set<AnyCancellable>()
        private var startTime: TimeInterval = Date().timeIntervalSince1970
        private var second = 0
        
        init(title: String, subtitle: String? = nil, state: State) {
            
            self.title = title
            self.subtitle = subtitle
            self.state = state
        }
        
        init(phoneNumber: String, repeatTimeInterval: TimeInterval) {
            
            self.title = "Код отправлен на " + phoneNumber
            self.subtitle = "Запросить повторно можно через"
            self.state = .timer(.init(value: ""))

            bind()
        }
        
        func bind() {

            timer
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] time in

                    if time.timeIntervalSince1970 - startTime >= 9 {
                        subtitle = ""
                        state = .button(.init(action: {

                            subtitle = "Запросить повторно можно через"
                            startTime = Date().timeIntervalSince1970
                            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        }))
                    } else {
                        second = Int(10 - time.timeIntervalSince1970 + startTime)
                        state = .timer(.init(value: timerMask(timeInSeconds: second)))
                    }
                }.store(in: &bindings)
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

            init(action: @escaping () -> Void = {}) {

                self.action = action
            }
        }
        
        func timerMask(timeInSeconds: Int) -> String {

            let minutes = timeInSeconds / 60
            let restOfSeconds = timeInSeconds % 60
            let secondString =  restOfSeconds / 10 > 0 ? String(restOfSeconds) : "0" + String(restOfSeconds)
            
            let returnedSting = minutes / 10 > 0 ? (String(minutes) + ":" + secondString) : ("0" + String(minutes) + ":" + secondString)
            
            return(returnedSting)
        }
    }
}

enum AuthConfirmViewModelAction {
    
    struct Dismiss: Action {}
    struct ViewDidAppear: Action {}
    struct SendAgain: Action {}
    struct ConfirmCode: Action {
        
        let code: String
    }
}

//MARK: - Samples

extension AuthConfirmViewModel {
    
    static let sampleConfirm: AuthConfirmViewModel = {
        
        let codeViewModel = CodeViewModel(title: "Введите код из сообщения", lenght: 6, state: .openening)
        let infoViewModel = InfoViewModel(title: "+7 ... ... 54 13", subtitle: nil, state: .timer(.init(value: "00:59")))
        let viewModel = AuthConfirmViewModel(navigationBar: .init(action: {}), code: codeViewModel, info: infoViewModel, numberOfPasswordAttempts: 5)
        
        return viewModel
    }()
}
