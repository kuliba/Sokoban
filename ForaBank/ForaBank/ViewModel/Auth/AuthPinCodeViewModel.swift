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
    
    @Published var mode: Mode
    @Published var stage: Stage
    
    @Published var isPermissionsViewPresented: Bool
    var permissionsViewModel: AuthPermissionsViewModel?
    
    @Published var alert: Alert.ViewModel?
    
    private let model: Model
    private let backAction: () -> Void
    private let dismissAction: () -> Void
    private var bindings = Set<AnyCancellable>()

    init(pinCode: PinCodeViewModel, numpad: NumPadViewModel, footer: FooterViewModel, backAction: @escaping () -> Void, dismissAction: @escaping () -> Void, model: Model = .emptyMock, mode: Mode = .unlock(attempt: 3), stage: Stage = .editing, isPermissionsViewPresented: Bool = false) {
        
        self.pinCode = pinCode
        self.numpad = numpad
        self.footer = footer
        self.backAction = backAction
        self.dismissAction = dismissAction
        self.model = model
        self.mode = mode
        self.stage = stage
        self.isPermissionsViewPresented = isPermissionsViewPresented
    }
    
    init(_ model: Model, mode: Mode, backAction: @escaping () -> Void, dismissAction: @escaping () -> Void) {
 
        switch mode {
        case .unlock:
            self.pinCode = PinCodeViewModel(title: "Введите код", pincodeLength: model.pincodeLength)
            
            if let sensor = model.availableBiometricSensorType, model.isBiometricSensorEnabled == true {
                
                self.numpad = NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .icon(sensor.icon), action: .sensor))
                
            } else {
                
                self.numpad = NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .empty, action: .none))
            }
    
            self.footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            self.mode = mode

        case .create:
            self.pinCode = PinCodeViewModel(title: "Придумайте код", pincodeLength: model.pincodeLength)
            self.numpad = NumPadViewModel(leftButton: .init(type: .empty, action: .none), rightButton: .init(type: .icon(.ic40Delete), action: .delete))
            self.footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            self.mode = .create(step: .one)
        }
        
        self.backAction = backAction
        self.dismissAction = dismissAction
        self.stage = .editing
        self.isPermissionsViewPresented = false
        self.model = model
        
        bind()
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.Pincode.Check.Response:
                    switch payload {
                    case .correct:
                        withAnimation {
                            // show correct pincode state
                            pinCode.style = .correct
                            numpad.isEnabled = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                            
                            self.dismissAction()
                        }
                        
                    case .incorrect(remain: let remainAttempts):
                        guard case .unlock(attempt: let lastAttempt) = mode else {
                            return
                        }
                        mode = .unlock(attempt: lastAttempt + 1)
                        
                        withAnimation {
                            // show incorrect pincode state
                            pinCode.style = .incorrect
                            numpad.isEnabled = false
                        }
                        alert = .init(title: "Введен некорректный пин-код.", message: "Осталось попыток: \(remainAttempts)", primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.action.send(AuthPinCodeViewModelAction.Unlock.Attempt()) }))
     
                    case .restricted:
                        withAnimation {
                            // show incorrect pincode state
                            pinCode.style = .incorrect
                            numpad.isEnabled = false
                        }
                        alert = .init(title: "Введен некорректный пин-код.", message: "Все попытки исчерпаны.", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.action.send(AuthPinCodeViewModelAction.Unlock.Failed()) }))
                        
                    case .failure(message: let message):
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
     
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        numpad.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as NumPadViewModelAction.Button:
                    switch payload {
                    case .digit(let number):
                        pinCode.value = pinCode.value + String(number)
                    
                    case .delete:
                        guard pinCode.value.count > 0 else {
                            return
                        }
                        pinCode.value = String(pinCode.value.dropLast())
                        
                    case .sensor:
                        guard let sensor = model.availableBiometricSensorType, model.isBiometricSensorEnabled == true else {
                            return
                        }
                        model.action.send(ModelAction.Auth.Sensor.Evaluate.Request(sensor: sensor))
      
                    case .back:
                        self.mode = .create(step: .one)
                        self.pinCode.title = "Придумайте код"
                        self.pinCode.value = ""
                        self.numpad.update(button: .init(type: .empty, action: .none), left: true)

                    case .exit:
                        alert = .init(title: "Внимание!", message: "Вы действительно хотите выйти из аккаунта?", primary: .init(type: .cancel, title: "Отмена", action: {}), secondary: .init(type: .distructive, title: "Выйти", action: { [weak self] in self?.action.send(AuthPinCodeViewModelAction.Exit())}))
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        pinCode.$value
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                if pinCode.isComplete == true {
                    
                    switch mode {
                    case .unlock:
                        stage = .finished
                        
                    case .create(let step):
                        switch step {
                        case .one:
                            self.mode = .create(step: .two(value))
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                
                                self.pinCode.title = "Подтвердите код"
                                self.pinCode.value = ""
                                self.numpad.update(button: .init(type: .text("Назад"), action: .back), left: true)
                            }

                        case .two(let prevValue):
                            if value != prevValue {
                                
                                self.stage = .mistake
                                
                            } else {
                                
                                self.stage = .finished
                            }
                        }
                    }
                    
                } else {
                    
                    switch mode {
                    case .unlock:
                        
                        if pinCode.value.count > 0 {
                            
                            self.numpad.update(button: .init(type: .icon(.ic40Delete), action: .delete), left: false)
                            
                        } else {
                            
                            if let sensor = model.availableBiometricSensorType, model.isBiometricSensorEnabled == true {
                                
                                self.numpad.update(button: .init(type: .icon(sensor.icon), action: .sensor), left: false)
                                
                            } else {
                                
                                self.numpad.update(button: .init(type: .empty, action: .none), left: false)
                            }
                        }
                        
                    default:
                        break
                    }
                }
                
            }.store(in: &bindings)
        
        $stage
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] stage in
  
                switch stage {
                case .mistake:
                    withAnimation {
                        // show incorrect pincode state
                        pinCode.style = .incorrect
                        numpad.isEnabled = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                        
                        withAnimation {
                            // back to editing
                            self.stage = .editing
                            pinCode.style = .normal
                            pinCode.value = ""
                            numpad.isEnabled = true
                        }
                    }
                    
                case .finished:
                    
                    // lock numpad
                    numpad.isEnabled = false
                    
                    switch mode {
                    case .unlock(let attempt):
                        model.action.send(ModelAction.Auth.Pincode.Check.Request(pincode: pinCode.value, attempt: attempt))
                        
                    case .create:
                        withAnimation {
                            pinCode.style = .correct
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                            
                            model.action.send(ModelAction.Auth.Pincode.Set.Request(pincode: pinCode.value))
                            
                            if let sensor = model.availableBiometricSensorType {
                                
                                permissionsViewModel = .init(model, sensorType: sensor, dismissAction: dismissAction)
                                isPermissionsViewPresented = true
                                
                            } else {
                                
                                dismissAction()
                            }
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as AuthPinCodeViewModelAction.Continue:
                    guard case .unlock(attempt: let attempt) = mode else {
                        return
                    }
                    let currentAttempt = attempt + 1
                    mode = .unlock(attempt: currentAttempt)
                    model.action.send(ModelAction.Auth.Pincode.Check.Request(pincode: payload.code, attempt: currentAttempt))
                    
                case _ as AuthPinCodeViewModelAction.Unlock.Attempt:
                    alert = nil
                    withAnimation {
                        // back to editing
                        self.stage = .editing
                        pinCode.style = .normal
                        pinCode.value = ""
                        numpad.isEnabled = true
                    }
                    
                case _ as AuthPinCodeViewModelAction.Unlock.Failed:
                    alert = nil
                    model.action.send(ModelAction.Auth.Logout())
                    backAction()
                    
                case _ as AuthPinCodeViewModelAction.Exit:
                    model.action.send(ModelAction.Auth.Logout())
                    backAction()
                
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension AuthPinCodeViewModel {
    
    enum Mode {
        
        // unlock screen mode
        case unlock(attempt: Int)
        
        // create pincode mode
        case create(step: Step)
        
        enum Step {
            
            // entering first time pincode
            case one
            
            // entering second time pincode
            case two(String)
        }
    }
    
    enum Stage {
        
        case editing
        case mistake
        case finished
    }
}

//MARK: - PinCodeViewModel

extension AuthPinCodeViewModel {
    
    class PinCodeViewModel: ObservableObject {

        @Published var title: String
        @Published var value: String
        @Published var dots: [DotViewModel]
        @Published var style: Style
        
        var isComplete: Bool { value.count >= pincodeLength }
        
        private let pincodeLength: Int
        private var bindings = Set<AnyCancellable>()
        
        init(title: String, pincodeLength: Int, pincode: String = "", style: Style = .normal) {
            
            self.title = title
            self.value = pincode
            self.dots = Self.dots(pincode: pincode, length: pincodeLength)
            self.style = style
            self.pincodeLength = pincodeLength
            
            bind()
        }
        
        func bind() {
            
            $value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
 
                    dots = Self.dots(pincode: value, length: pincodeLength)
                    
                }.store(in: &bindings)
        }
        
        
        static func dots(pincode: String, length: Int) -> [DotViewModel] {
            
            return (0..<length).map{ pincode.count > $0 ? .init(isFilled: true) : .init(isFilled: false) }
        }
        
        enum Style {

            case normal
            case incorrect
            case correct
        }
        
        struct DotViewModel: Identifiable {
            
            let id = UUID()
            let isFilled: Bool
        }
    }
}

//MARK: - NumPadViewModel

extension AuthPinCodeViewModel {
    
    class NumPadViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var buttons: [[ButtonViewModel]]
        @Published var isEnabled: Bool
        
        init(buttons: [[ButtonViewModel]], isEnabled: Bool = true) {
            
            self.buttons = buttons
            self.isEnabled = isEnabled
        }
        
        init(leftButton: ButtonData, rightButton: ButtonData) {
            
            self.buttons = [[]]
            self.isEnabled = true
            
            self.buttons =  [[.init(type: .digit("1"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(1)) }),
                              .init(type: .digit("2"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(2)) }),
                              .init(type: .digit("3"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(3)) })],
           
                             [.init(type: .digit("4"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(4)) }),
                              .init(type: .digit("5"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(5)) }),
                              .init(type: .digit("6"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(6)) })],

                             [.init(type: .digit("7"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(7)) }),
                              .init(type: .digit("8"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(8)) }),
                              .init(type: .digit("9"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(9)) })],
           
                             [.init(type: leftButton.type,
                                    action: { [weak self] in self?.action.send(leftButton.action) }),
                              .init(type: .digit("0"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(9)) }),
                              .init(type: rightButton.type,
                                    action: { [weak self] in self?.action.send(rightButton.action) })]]
        }
        
        func update(button: ButtonData, left: Bool) {
            
            let buttonViewModel = ButtonViewModel(type: button.type, action: { [weak self] in self?.action.send(button.action) })
            
            var updated = [[ButtonViewModel]]()
            
            updated.append(buttons[0])
            updated.append(buttons[1])
            updated.append(buttons[2])
            
            if left == true {
                
                updated.append([buttonViewModel, buttons[3][1], buttons[3][2]])
                
            } else {
                
                updated.append([buttons[3][0], buttons[3][1], buttonViewModel])
            }
            
            buttons = updated
        }
        
        struct ButtonData {
            
            let type: ButtonViewModel.Kind
            let action: NumPadViewModelAction.Button
        }
        
        struct ButtonViewModel: Identifiable, Hashable {

            let id = UUID()
            let type: Kind
            let action: () -> Void
            
            enum Kind {
                
                case digit(String)
                case icon(Image)
                case text(String)
                case empty
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(id)
            }
            
            static func == (lhs: ButtonViewModel, rhs: ButtonViewModel) -> Bool {
                
                return lhs.id == rhs.id
            }
        }
    }
    
    enum NumPadViewModelAction: Action {
        
        enum Button: Action {
            
            case digit(Int)
            case delete
            case sensor
            case back
            case exit
            case none
        }
    }
}

//MARK: - FooterViewModel

extension AuthPinCodeViewModel {
    
    class FooterViewModel: ObservableObject {
        
        @Published var continueButton: ButtonViewModel?
        @Published var cancelButton: ButtonViewModel?
        
        struct ButtonViewModel {
            
            let title: String
            let action: () -> Void
        }
        
        internal init(continueButton: ButtonViewModel?, cancelButton: ButtonViewModel?) {

            self.continueButton = continueButton
            self.cancelButton = cancelButton
        }
    }
}

//MARK: - Actions

enum AuthPinCodeViewModelAction {

    struct Cancel: Action {}
    
    struct Continue: Action {

        let code: String
    }
    
    struct Exit: Action {}
    
    enum Unlock {
        
        struct Attempt: Action {}
        
        struct Failed: Action {}
    }
}
