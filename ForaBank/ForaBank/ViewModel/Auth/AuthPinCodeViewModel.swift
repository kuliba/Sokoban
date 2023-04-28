//
//  AuthPinCodeViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 10.02.2022.
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox

class AuthPinCodeViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()
    
    let pincodeValue: CurrentValueSubject<String, Never>
    let pinCode: PinCodeViewModel
    @Published var numpad: NumPadViewModel
    @Published var footer: FooterViewModel
    @Published var spinner: SpinnerView.ViewModel?
    
    @Published var mode: Mode
    @Published var stage: Stage
    
    @Published var isPermissionsViewPresented: Bool
    var permissionsViewModel: AuthPermissionsViewModel?
    
    @Published var alert: Alert.ViewModel?
    @Published var mistakes: Int
    
    private var sensorAutoEvaluationStatus: SensorAutoEvaluationStatus?
    private var viewDidAppear: CurrentValueSubject<Bool, Never>
    
    private let model: Model
    private let rootActions: RootViewModel.RootActions
    private var bindings = Set<AnyCancellable>()
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var isPincodeComplete: Bool { pincodeValue.value.count >= model.authPincodeLength }

    init(pincodeValue: CurrentValueSubject<String, Never>, pinCode: PinCodeViewModel, numpad: NumPadViewModel, footer: FooterViewModel, rootActions: RootViewModel.RootActions, model: Model = .emptyMock, mode: Mode = .unlock(attempt: 3, auto: false), stage: Stage = .editing, isPermissionsViewPresented: Bool = false, mistakes: Int = 0, sensorAutoEvaluationStatus: SensorAutoEvaluationStatus? = nil, isViewDidAppear: Bool = false, spinner: SpinnerView.ViewModel? = nil) {
        
        self.pincodeValue = pincodeValue
        self.pinCode = pinCode
        self.numpad = numpad
        self.footer = footer
        self.rootActions = rootActions
        self.model = model
        self.mode = mode
        self.stage = stage
        self.isPermissionsViewPresented = isPermissionsViewPresented
        self.mistakes = mistakes
        self.sensorAutoEvaluationStatus = sensorAutoEvaluationStatus
        self.viewDidAppear = .init(isViewDidAppear)
        self.spinner = spinner
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "initialized")
    }
    
    convenience init(_ model: Model, mode: Mode, rootActions: RootViewModel.RootActions) {
 
        switch mode {
        case .unlock(attempt: _, auto: let isAutoSensor):
            let pinCode = PinCodeViewModel(title: "Введите код", pincodeLength: model.authPincodeLength)
            let footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            
            if let sensor = model.authAvailableBiometricSensorType, model.authIsBiometricSensorEnabled == true {
                
                let numpad = NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .icon(sensor.icon), action: .sensor))
                
                if isAutoSensor == true {
                    
                    self.init(pincodeValue: .init(""),
                              pinCode: pinCode,
                              numpad: numpad,
                              footer: footer,
                              rootActions: rootActions,
                              model: model,
                              mode: mode,
                              stage: .editing,
                              sensorAutoEvaluationStatus: .required(sensor))
                    
                } else {
                    
                    self.init(pincodeValue: .init(""), pinCode: pinCode, numpad: numpad, footer: footer, rootActions: rootActions, model: model, mode: mode, stage: .editing)
                }
                
            } else {
                
                let numpad = NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .empty, action: .none))
                
                self.init(pincodeValue: .init(""), pinCode: pinCode, numpad: numpad, footer: footer, rootActions: rootActions, model: model, mode: mode, stage: .editing)
            }
            
            model.action.send(ModelAction.Auth.Session.Start.Request())
            
        case .create:
            let pinCode = PinCodeViewModel(title: "Придумайте код", pincodeLength: model.authPincodeLength)
            let numpad = NumPadViewModel(leftButton: .init(type: .empty, action: .none), rightButton: .init(type: .icon(.ic40Delete), action: .delete))
            let footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            
            self.init(pincodeValue: .init(""), pinCode: pinCode, numpad: numpad, footer: footer, rootActions: rootActions, model: model, mode: mode, stage: .editing)
        }
 
        bind()
    }
    
    func bind() {
        
        model.sessionState
            .combineLatest(model.clientInform, self.viewDidAppear)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state, clientInformData, isViewDidAppear in
        
                switch state {
                
                case .active:
                    
                    guard clientInformData.isRecieved, isViewDidAppear else { return }
                    
                    withAnimation {
                        self.spinner = nil
                    }
                        
                    if !self.model.clientInformStatus.isShowNotAuthorized,
                       let message = clientInformData.data?.notAuthorized  {
                       
                        self.action.send(AuthPinCodeViewModelAction.Show.AlertClientInform(message: message))
                    
                    } else {
                    
                        tryAutoEvaluateSensor()
                    }
                    
                default:
                    withAnimation {
                        self.spinner = .init()
                    }
                }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.Pincode.Check.Response:
                    switch payload {
                    case .correct:
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Check.Response: correct")
                        withAnimation {
                            // show correct pincode state
                            pinCode.style = .correct
                            numpad.isEnabled = false
                        }
                        
                        // taptic feedback
                        feedbackGenerator.notificationOccurred(.success)
                        
                        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Login.Request, type: .pin, restartSession: false")
                        self.model.action.send(ModelAction.Auth.Login.Request(type: .pin, restartSession: false))
                        
                    case .incorrect(remain: let remainAttempts):
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Check.Response: incorrect, remain attempts: \(remainAttempts)")
                        guard case .unlock(attempt: let lastAttempt, auto: let auto) = mode else {
                            return
                        }
                        mode = .unlock(attempt: lastAttempt + 1, auto: auto)
                        
                        withAnimation {
                            // show incorrect pincode state
                            mistakes += 1
                            pinCode.style = .incorrect
                            numpad.isEnabled = false
                        }
                        // error sound
                        AudioServicesPlaySystemSound(1109)
                        // taptic feedback
                        feedbackGenerator.notificationOccurred(.error)
                        alert = .init(title: "Введен некорректный пин-код.", message: "Осталось попыток: \(remainAttempts)", primary: .init(type: .default, title: "Ok", action: {[weak self] in
                            
                            self?.alert = nil
                            LoggerAgent.shared.log(category: .ui, message: "sent AuthPinCodeViewModelAction.Unlock.Attempt")
                            self?.action.send(AuthPinCodeViewModelAction.Unlock.Attempt())
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                        
                    case .restricted:
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Check.Response: restricted")
                        withAnimation {
                            // show incorrect pincode state
                            pinCode.style = .incorrect
                            numpad.isEnabled = false
                        }
                        alert = .init(title: "Введен некорректный пин-код.", message: "Все попытки исчерпаны.", primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            
                            self?.alert = nil
                            LoggerAgent.shared.log(category: .ui, message: "sent AuthPinCodeViewModelAction.Unlock.Failed")
                            self?.action.send(AuthPinCodeViewModelAction.Unlock.Failed())
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                        
                    case .failure(message: let message):
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Check.Response: failure, message: \(message)")
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                    }
                    
                case let payload as ModelAction.Auth.Sensor.Evaluate.Response:
                    if sensorAutoEvaluationStatus != nil {
                        sensorAutoEvaluationStatus = .evaluated
                    }
                    
                    switch payload {
                    case .success(let sensorType):
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Sensor.Evaluate.Response: success, sensor type: \(sensorType)")
                        
                        // lock numpad
                        numpad.isEnabled = false
                        
                        // taptic feedback
                        feedbackGenerator.notificationOccurred(.success)
                        
                        pinCode.update(with: "0000", pincodeLength: model.authPincodeLength)
                        pinCode.style = .correct
                        
                        withAnimation {
                            
                            pinCode.isAnimated = true
                        }
                        
                        switch sensorType {
                        case .face:
                            LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Login.Request, type: .faceId, restartSession: false")
                            self.model.action.send(ModelAction.Auth.Login.Request(type: .faceId, restartSession: false))
                            
                        case .touch:
                            LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Login.Request, type: .touchId, restartSession: false")
                            self.model.action.send(ModelAction.Auth.Login.Request(type: .touchId, restartSession: false))
                        }

                    case .failure(message: let message):
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Sensor.Evaluate.Response: failure, message: \(message)")
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil}))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                    }
                    
                case let payload as ModelAction.Auth.Pincode.Set.Response:
                    switch payload {
                    case .success:
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Set.Response: success")
                        feedbackGenerator.notificationOccurred(.success)
                        if let sensor = model.authAvailableBiometricSensorType {
                            
                            let permissionsViewModel = AuthPermissionsViewModel(model, sensorType: sensor, dismissAction: {})
                            
                            LoggerAgent.shared.log(category: .ui, message: "show sensor permissions view")
                            self.permissionsViewModel = permissionsViewModel
                            isPermissionsViewPresented = true
                            
                            bind(permissionsViewModel)
                            
                        } else {
                            
                            LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.SetDeviceSettings.Request, sensor: nil")
                            model.action.send(ModelAction.Auth.SetDeviceSettings.Request(sensorType: nil))
                        }
                        
                    case .failure(message: let message):
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Pincode.Set.Response: failure, message: \(message)")
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: {[weak self] in
                            
                            //TODO: set pincode failed with error. Back to login or try again?
                            
                            self?.alert = nil
                            
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                    }
                    
                case let payload as ModelAction.Auth.SetDeviceSettings.Response:
                    switch payload {
                    case .success:
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.SetDeviceSettings.Response: success")
                        
                        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Login.Request, type: .pin, restartSession: true")
                        model.action.send(ModelAction.Auth.Login.Request(type: .pin, restartSession: true))
                        
                    case .failure:
                        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.SetDeviceSettings.Response: failure")
                        
                        rootActions.spinner.hide()
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "hide spinner")
                        alert = Alert.ViewModel(title: "Ошибка", message: model.defaultErrorMessage, primary: .init(type: .default, title: "Ok", action: {[weak self] in
                            
                            self?.alert = nil
                            LoggerAgent.shared.log(category: .ui, message: "sent AuthPinCodeViewModelAction.Unlock.Attempt")
                            self?.action.send(AuthPinCodeViewModelAction.Unlock.Attempt())
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                    }
                    
                case let payload as ModelAction.Auth.Login.Response:
                    LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.Login.Response")
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "hide spinner")
                    rootActions.spinner.hide()
                    
                    switch payload {
                    case .failure(message: let message):
                        LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.Login.Response: failure, message: \(message)")
                        alert = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: {[weak self] in
                            
                            self?.alert = nil
                            LoggerAgent.shared.log(category: .ui, message: "sent AuthPinCodeViewModelAction.Unlock.Attempt")
                            self?.action.send(AuthPinCodeViewModelAction.Unlock.Attempt())
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                        
                    default:
                        break
                        
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
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "NumPadViewModelAction.Button: digit")
                        pincodeValue.value = pincodeValue.value + String(number)
                        // button click sound
                        AudioServicesPlaySystemSound(1104)
                    
                    case .delete:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "NumPadViewModelAction.Button: delete")
                        guard pincodeValue.value.count > 0 else {
                            return
                        }
                        pincodeValue.value = String(pincodeValue.value.dropLast())
                        // delete click sound
                        AudioServicesPlaySystemSound(1155)
                        
                    case .sensor:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "NumPadViewModelAction.Button: sensor")
                        guard let sensor = model.authAvailableBiometricSensorType, model.authIsBiometricSensorEnabled == true else {
                            return
                        }
                        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Sensor.Evaluate.Request")
                        model.action.send(ModelAction.Auth.Sensor.Evaluate.Request(sensor: sensor))
                        // option click sound
                        AudioServicesPlaySystemSound(1156)
      
                    case .back:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "NumPadViewModelAction.Button: back")
                        self.mode = .create(step: .one)
                        self.pinCode.title = "Придумайте код"
                        self.pincodeValue.value = ""
                        self.numpad.update(button: .init(type: .empty, action: .none), left: true)
                        // option click sound
                        AudioServicesPlaySystemSound(1156)

                    case .exit:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "NumPadViewModelAction.Button: exit")
                        alert = .init(title: "Внимание!", message: "Вы действительно хотите выйти из аккаунта?", primary: .init(type: .cancel, title: "Отмена", action: {}), secondary: .init(type: .default, title: "Выйти", action: { [weak self] in
                            
                            self?.alert = nil
                            LoggerAgent.shared.log(category: .ui, message: "sent AuthPinCodeViewModelAction.Exit")
                            self?.action.send(AuthPinCodeViewModelAction.Exit())
                        }))
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "show alert")
                        AudioServicesPlaySystemSound(1156)
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        pincodeValue
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                pinCode.update(with: value, pincodeLength: model.authPincodeLength)
                
                if isPincodeComplete == true {
                    
                    switch mode {
                    case .unlock:
                        stage = .finished
                        
                    case .create(let step):
                        switch step {
                        case .one:
                            self.mode = .create(step: .two(value))
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                
                                self.pinCode.title = "Подтвердите код"
                                self.pincodeValue.value = ""
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
                        
                        if pincodeValue.value.count > 0 {
                            
                            self.numpad.update(button: .init(type: .icon(.ic40Delete), action: .delete), left: false)
                            
                        } else {
                            
                            if let sensor = model.authAvailableBiometricSensorType, model.authIsBiometricSensorEnabled == true {
                                
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
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] stage in
  
                switch stage {
                case .mistake:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "stage: mistake")
                    pinCode.isAnimated = false
                    withAnimation {
                        // show incorrect pincode state
                        mistakes += 1
                        pinCode.style = .incorrect
                        numpad.isEnabled = false
                    }
                    // error sound
                    AudioServicesPlaySystemSound(1109)
                    // taptic feedback
                    feedbackGenerator.notificationOccurred(.error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) { [self] in
                        
                        withAnimation {
                            // back to editing
                            self.stage = .editing
                            self.pinCode.style = .normal
                            self.pincodeValue.value = ""
                            self.numpad.isEnabled = true
                        }
                    }
                    
                case .finished:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "stage: finished")
                    // lock numpad
                    numpad.isEnabled = false
                    
                    switch mode {
                    case .unlock(let attempt, auto: _):
                        withAnimation {
                            pinCode.isAnimated = true
                        }
                        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Pincode.Check.Request")
                        model.action.send(ModelAction.Auth.Pincode.Check.Request(pincode: pincodeValue.value, attempt: attempt))
                        
                    case .create:
                        pinCode.style = .correct
                        withAnimation {
                            pinCode.isAnimated = true
                        }
                        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Pincode.Set.Request")
                        model.action.send(ModelAction.Auth.Pincode.Set.Request(pincode: pincodeValue.value))
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as AuthPinCodeViewModelAction.Appear:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received AuthPinCodeViewModelAction.Appear")
                    self.viewDidAppear.send(true)
                    
                case let payload as AuthPinCodeViewModelAction.Continue:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPinCodeViewModelAction.Continue")
                    guard case .unlock(attempt: let attempt, auto: let auto) = mode else {
                        return
                    }
                    let currentAttempt = attempt + 1
                    mode = .unlock(attempt: currentAttempt, auto: auto)
                    LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Pincode.Check.Request, pincode, attempt: \(currentAttempt)")
                    model.action.send(ModelAction.Auth.Pincode.Check.Request(pincode: payload.code, attempt: currentAttempt))
                    
                case _ as AuthPinCodeViewModelAction.Unlock.Attempt:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPinCodeViewModelAction.Unlock.Attempt")
                    alert = nil
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "hide alert")
                    withAnimation {
                        // back to editing
                        self.stage = .editing
                        pinCode.style = .normal
                        pincodeValue.value = ""
                        numpad.isEnabled = true
                    }
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "reset pincode")
                    
                case _ as AuthPinCodeViewModelAction.Unlock.Failed:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPinCodeViewModelAction.Unlock.Failed")
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Logout")
                    model.action.send(ModelAction.Auth.Logout())
                    
                case _ as AuthPinCodeViewModelAction.Exit:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPinCodeViewModelAction.Exit")
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Logout")
                    model.action.send(ModelAction.Auth.Logout())
                    
                case let payload as AuthPinCodeViewModelAction.Show.AlertClientInform:
                    LoggerAgent.shared.log(category: .ui,
                                           message: "received AuthPinCodeViewModelAction.Show.AlertClientInform with \(payload.message)")
                    
                    self.model.clientInformStatus.isShowNotAuthorized = true
                    alert = .init(title: "Ошибка",
                                  message: payload.message,
                                  primary: .init(type: .default,
                                                 title: "Ok",
                                                 action: { [weak self] in
                                                            self?.alert = nil
                                                            self?.tryAutoEvaluateSensor() }))
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(_ permissionsViewModel: AuthPermissionsViewModel) {
        
        permissionsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else {
                    return
                }
                
                switch action {
                case let payload as AuthPermissionsViewModelAction.Confirm:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPermissionsViewModelAction.Confirm")
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "show spinner")
                    self.rootActions.spinner.show()
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.SetDeviceSettings.Request, sensor: \(payload.sensorType)")
                    self.model.action.send(ModelAction.Auth.SetDeviceSettings.Request(sensorType: payload.sensorType))
                    
                case _ as AuthPermissionsViewModelAction.Skip:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthPermissionsViewModelAction.Skip")
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "show spinner")
                    self.rootActions.spinner.show()
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.SetDeviceSettings.Request, sensor: nil")
                    self.model.action.send(ModelAction.Auth.SetDeviceSettings.Request(sensorType: nil))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    var isAutoEvaluateSensorRequired: Bool {
        
        guard case .required(_) = sensorAutoEvaluationStatus else {
            return false
        }
        
        return true
    }
    
    func tryAutoEvaluateSensor() {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "Auto evaluate sensor attempt")
        
        guard case let .required(sensor) = sensorAutoEvaluationStatus
        else { return }
        
        LoggerAgent.shared.log(category: .ui, message: "sent ModelAction.Auth.Sensor.Evaluate.Request: sensor: \(sensor)")
        
        sensorAutoEvaluationStatus = .evaluating
        model.action.send(ModelAction.Auth.Sensor.Evaluate.Request(sensor: sensor))
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
}

//MARK: - Types

extension AuthPinCodeViewModel {
    
    enum Mode {
        
        // unlock screen mode
        case unlock(attempt: Int, auto: Bool)
        
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
    
    enum SensorAutoEvaluationStatus {
        
        case required(BiometricSensorType)
        case evaluating
        case evaluated
    }
    
    struct AutoEvaluatSensorState {

        var isAutoEvaluateSensorRequired: Bool
        var isActiveSession: Bool
        var isViewAppear: Bool
        var isTryAutoEvaluateSensor: Bool

        var isRequered: Bool {
            isAutoEvaluateSensorRequired == true &&
            isActiveSession == true &&
            isViewAppear == true &&
            isTryAutoEvaluateSensor == false }
    }
}

//MARK: - PinCodeViewModel

extension AuthPinCodeViewModel {
    
    class PinCodeViewModel: ObservableObject {

        @Published var title: String
        @Published var dots: [DotViewModel]
        @Published var style: Style
        @Published var isAnimated: Bool

        init(title: String, dots: [DotViewModel], style: Style, isAnimated: Bool = false) {
            
            self.title = title
            self.dots = dots
            self.style = style
            self.isAnimated = isAnimated
        }
        
        init(title: String, pincodeValue: String = "", pincodeLength: Int, style: Style = .normal) {
            
            self.title = title
            self.dots = Self.dots(pincodeValue, pincodeLength)
            self.style = style
            self.isAnimated = false
        }
        
        func update(with pincodeValue: String, pincodeLength: Int) {
            
            dots = Self.dots(pincodeValue, pincodeLength)
        }
        
        static private func dots(_ pincodeValue: String, _ pincodeLength: Int) -> [DotViewModel] {
            
            return (0..<pincodeLength).map{ pincodeValue.count > $0 ? .init(isFilled: true) : .init(isFilled: false) }
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
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(0)) }),
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
    
    struct Appear: Action {}
    
    enum Show {
        
        struct AlertClientInform: Action {
            
            let message: String
        }
    }
}
