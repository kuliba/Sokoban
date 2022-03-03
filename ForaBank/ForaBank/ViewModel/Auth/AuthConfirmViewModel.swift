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
    var pincodeViewModel: AuthPinCodeViewModel?
    
    @Published var alert: Alert.ViewModel?
    @Published var showingAlert: Bool

    private let phoneNumber: String
    private let resendCodeDelay: TimeInterval
    
    private var currentResendCodeAttempt = 0
    private let backAction: () -> Void
    private let rootActions: RootViewModel.AuthActions
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarViewModel, code: CodeViewModel, info: InfoViewModel?, isPincodeViewPresented: Bool = false, model: Model = .emptyMock, showingAlert: Bool = false, phoneNumber: String, resendCodeDelay: TimeInterval, backAction: @escaping () -> Void, rootActions: RootViewModel.AuthActions) {
        
        self.navigationBar = navigationBar
        self.code = code
        self.info = info
        self.isPincodeViewPresented = isPincodeViewPresented
        self.model = model
        self.showingAlert = showingAlert
        self.phoneNumber = phoneNumber
        self.resendCodeDelay = resendCodeDelay
        self.backAction = backAction
        self.rootActions = rootActions
    }
    
    init(_ model: Model, confirmCodeLength: Int, phoneNumber: String, resendCodeDelay: TimeInterval, backAction: @escaping () -> Void, rootActions: RootViewModel.AuthActions) {
        
        self.model = model
        self.navigationBar = NavigationBarViewModel(action: backAction)
        self.code = CodeViewModel(title: "Введите код из сообщения", lenght: confirmCodeLength, state: .openening)
        self.info = nil
        self.isPincodeViewPresented = false
        self.showingAlert = false
        self.phoneNumber = phoneNumber
        self.resendCodeDelay = resendCodeDelay
        self.backAction = backAction
        self.rootActions = rootActions
        
        bind()
        
        self.info = InfoViewModel(phoneNumber: phoneNumber, resendCodeDelay: resendCodeDelay, completeTimerAction: { [weak self] in self?.action.send(AuthConfirmViewModelAction.RepeatCode.DelayFinished()) })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            
            self.code.state = .edit
        }
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.VerificationCode.Confirm.Response:
                    rootActions.spinner.hide()
                    switch payload {
                    case .correct:
                        pincodeViewModel = AuthPinCodeViewModel(model, mode: .create(step: .one), backAction: backAction, dismissAction: rootActions.dismiss)
                        isPincodeViewPresented = true
                        
                    case .incorrect(let message):
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                            self?.code.state = .edit
                            self?.code.textField.text = ""
                            self?.code.textField.showKeyboard()
                        }))
                        
                    case .restricted(let message):
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.action.send(AuthConfirmViewModelAction.Dismiss())}))
                        
                    case .failure(message: let message):
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                            self?.code.state = .edit
                            self?.code.textField.text = ""
                            self?.code.textField.showKeyboard()
                        }))
                    }
                    
                case let payload as ModelAction.Auth.VerificationCode.Resend.Response:
                    switch payload {
                    case .success(remain: let remain):
                        if remain > 0 {
                            withAnimation {
                                
                                info?.state = .timer(.init(delay: resendCodeDelay, description: "Осталось попыток запросить код повторно: \(remain)", completeAction: { [weak self] in self?.action.send(AuthConfirmViewModelAction.RepeatCode.DelayFinished()) }))
                            }
                        
                        } else {
                            
                            alert = Alert.ViewModel(title: "Вы исчерпали все попытки.", message: "Попробуйте позже.", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.action.send(AuthConfirmViewModelAction.Dismiss())}))
                        }
                        
                    case .failure(message: let message):
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    guard payload.code.count == code.codeLenght else {
                        return
                    }
                    code.textField.text = payload.code
 
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as AuthConfirmViewModelAction.RepeatCode.DelayFinished:
                    withAnimation {
                        info?.state = .button(.init(action: { [weak self] in self?.action.send(AuthConfirmViewModelAction.RepeatCode.Requested())}))
                    }
                    
                case _ as AuthConfirmViewModelAction.RepeatCode.Requested:
                    currentResendCodeAttempt += 1
                    model.action.send(ModelAction.Auth.VerificationCode.Resend.Request(attempt: currentResendCodeAttempt))
                    
                case _ as AuthConfirmViewModelAction.Dismiss:
                    alert = nil
                    backAction()
    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        code.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .edit:
                    code.textField.showKeyboard()
                    code.code = code.setupCode(codeLenght: code.codeLenght)
                    code.textField.text = ""
                    
                case .check:
                    code.textField.dismissKeyboard()
                    rootActions.spinner.show()
                    model.action.send(ModelAction.Auth.VerificationCode.Confirm.Request(code: code.textField.text))
                    
                default:
                    break
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

        let title: String
        let codeLenght: Int
        @Published var code: [String?]
        let textField: TextFieldViewModel
        @Published var state: State
        private var bindings = Set<AnyCancellable>()
        
        internal init(title: String, codeLenght: Int, code: [String?], textField: TextFieldViewModel, showKeyboard: Bool, state: State) {
            self.title = title
            self.codeLenght = codeLenght
            self.code = code
            self.textField = textField
            self.state = state
            bind()
        }
        
        init(title: String, lenght: Int, state: State) {

            self.title = title
            self.codeLenght = lenght
            self.code = []
            self.textField = TextFieldViewModel()
            self.state = state
            
            code = setupCode(codeLenght: codeLenght)
            bind()
        }

        func bind() {

            textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in

                    guard state == .edit else { return }
                    
                    let codeDigits = extractDigits(value: text)
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
        
        class TextFieldViewModel: ObservableObject {
            
            @Published var text: String = ""
            var dismissKeyboard: () -> Void = {}
            var showKeyboard: () -> Void = {}
        }
        
        enum State {
     
            case edit
            case check
            case openening
        }
    }
    
    class InfoViewModel: ObservableObject {
        
        var title: String
        @Published var state: State

        private var bindings = Set<AnyCancellable>()
  
        init(title: String, subtitle: String? = nil, state: State) {
            
            self.title = title
            self.state = state
        }
        
        init(phoneNumber: String, resendCodeDelay: TimeInterval, completeTimerAction: @escaping () -> Void) {
            
            self.title = "Код отправлен на " + phoneNumber
            self.state = .timer(.init(delay: resendCodeDelay, description: "Запросить повторно можно через:", completeAction: completeTimerAction))
        }

        enum State {
            
            case timer(TimerViewModel)
            case button(RepeatButtonViewModel)
        }
        
        class TimerViewModel: ObservableObject {
      
            let delay: TimeInterval
            let description: String
            @Published var value: String
            let completeAction: () -> Void
            
            private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            private let startTime = Date.timeIntervalSinceReferenceDate
            private var formatter: DateComponentsFormatter = {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .short
                formatter.allowedUnits = [.minute, .second]
                return formatter
            }()
            private var bindings = Set<AnyCancellable>()
            
            init(delay: TimeInterval, description: String, completeAction: @escaping () -> Void) {
                
                self.delay = delay
                self.description = description
                self.value = ""
                self.completeAction = completeAction
                
                bind()
                value = formatter.string(from: delay) ?? "0 :\(delay)"
            }
            
            func bind() {
                
                timer
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] time in

                        let delta = time.timeIntervalSinceReferenceDate - startTime
                        let remain = delay - delta
                        
                        if remain <= 1 { completeAction() }
                       
                        value = formatter.string(from: remain) ?? "0 :\(remain)"
                        
                    }.store(in: &bindings)
                
            }
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

    enum RepeatCode {
        
        struct DelayFinished: Action {}
        
        struct Requested: Action {}
    }
 
    struct ConfirmCode: Action {
        
        let code: String
    }
}

//MARK: - Samples

extension AuthConfirmViewModel {
    
    static let sampleConfirm: AuthConfirmViewModel = {
        
        let codeViewModel = CodeViewModel(title: "Введите код из сообщения", lenght: 6, state: .openening)
        let infoViewModel = InfoViewModel(title: "+7 ... ... 54 13", subtitle: "Повторно отправить можно через:", state: .button(.init(action: {})))
        let viewModel = AuthConfirmViewModel(navigationBar: .init(action: {}), code: codeViewModel, info: infoViewModel, isPincodeViewPresented: false, model: .emptyMock, showingAlert: false, phoneNumber: "+7 ... ... 54 13", resendCodeDelay: 60, backAction: {}, rootActions: .init(dismiss: {}, spinner: .init(show: {}, hide: {})))
        
        return viewModel
    }()
}
