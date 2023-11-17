//
//  ConfirmViewModel.swift
//
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import Foundation
import Combine
import Tagged

public class ConfirmViewModel: ObservableObject {
    
    public typealias ChangePinHandler = (ChangePinStruct, @escaping (ErrorDomain?) -> Void) -> Void
    public typealias OtpHandler =  (OtpDomain.Otp, @escaping (ErrorDomain?) -> Void) -> Void
    let maxDigits: Int
    
    @Published var otp: OtpDomain.Otp
    @Published var isDisabled: Bool
    @Published var showAlert: Bool
    
    let action: PassthroughSubject<ComfirmViewAction, Never> = .init()
    
    let phoneNumber: PhoneDomain.Phone
    let cardId: CardDomain.CardId
    let actionType: CVVPinAction
    var newPin: PinDomain.NewPin = ""
    
    let handler: OtpHandler
    let handlerChangePin: ChangePinHandler?
    
    let showSpinner: () -> Void
    let resendRequestAfterClose: (CardDomain.CardId, CVVPinAction) -> Void
    var infoForAllert: (
        alertMessage: String,
        buttonTitle: String?,
        oneButton: Bool,
        action: () -> Void
    ) = ("", nil, true, {})
    
    public init(
        phoneNumber: PhoneDomain.Phone,
        cardId: CardDomain.CardId,
        actionType: CVVPinAction,
        maxDigits: Int = 6,
        otp: OtpDomain.Otp = "",
        newPin: PinDomain.NewPin = "",
        isDisable: Bool = false,
        showAlert: Bool = false,
        handler: @escaping OtpHandler,
        handlerChangePin: ChangePinHandler? = nil,
        showSpinner: @escaping () -> Void,
        resendRequestAfterClose: @escaping (CardDomain.CardId, CVVPinAction) -> Void
    ) {
        self.phoneNumber = phoneNumber
        self.cardId = cardId
        self.actionType = actionType
        self.maxDigits = maxDigits
        self.otp = otp
        self.newPin = newPin
        self.isDisabled = isDisable
        self.showAlert = showAlert
        self.handler = handler
        self.handlerChangePin = handlerChangePin
        self.showSpinner = showSpinner
        self.resendRequestAfterClose = resendRequestAfterClose
    }
    
    func submitOtp() {
        
        guard !otp.isEmpty else { return }
        
        if otp.count == maxDigits && !isDisabled {
            
            isDisabled = true
            //showSpinner()
            if let handlerChangePin {
                let changePin = ChangePinStruct(
                    cardId: cardId,
                    newPin: newPin,
                    otp: otp)
                handlerChangePin(changePin) { result in
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let self else { return }
                        
                        switch result {
                            
                        case .none:
                            self.resendRequestAfterClose(self.cardId, .changePinResult(.successScreen))
                            self.action.send(ConfirmViewModelAction.Close.SelfView())
                            
                        case let .some(error):
                            switch error {
                            case let .pinError(error):
                                switch error {
                                case let .errorForAlert(message):
                                    self.isDisabled = false
                                    self.otp = ""
                                    self.infoForAllert.alertMessage = message.rawValue
                                    self.infoForAllert.oneButton = true
                                    self.showAlert = true
                                    
                                case .errorScreen:
                                    self.resendRequestAfterClose(self.cardId, .changePinResult(.errorScreen))
                                    self.action.send(ConfirmViewModelAction.Close.SelfView())
                                    
                                case let .weakPinAlert(message, buttonTitle):
                                    self.isDisabled = false
                                    self.otp = ""
                                    self.infoForAllert.alertMessage = message.rawValue
                                    self.infoForAllert.buttonTitle = buttonTitle.rawValue
                                    self.infoForAllert.oneButton = false
                                    self.infoForAllert.action = self.restartChangePin
                                    self.showAlert = true
                                }
                                
                            case .cvvError:
                                return
                            }
                        }
                    }
                }
            }
            else {
                handler(otp) { result in
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let self else { return }
                        
                        switch result {
                            
                        case .none:
                            self.resendRequestAfterClose(self.cardId, self.actionType)
                            self.action.send(ConfirmViewModelAction.Close.SelfView())
                            
                        case let .some(error):
                            switch error {
                            case .pinError:
                                return
                                
                            case let .cvvError(error):
                                switch error {
                                case let .errorForAlert(message):
                                    self.isDisabled = false
                                    self.otp = ""
                                    self.infoForAllert.alertMessage = message.rawValue
                                    self.infoForAllert.oneButton = true
                                    self.showAlert = true
                                    
                                case let .noRetry(message, buttonTitle):
                                    self.isDisabled = false
                                    self.otp = ""
                                    self.infoForAllert.alertMessage = message.rawValue
                                    self.infoForAllert.buttonTitle = buttonTitle.rawValue
                                    self.infoForAllert.oneButton = true
                                    self.infoForAllert.action = {
                                        self.action.send(ConfirmViewModelAction.Close.SelfView())
                                    }
                                    self.showAlert = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if otp.count > maxDigits {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                self.otp = .init(String(self.otp.rawValue.prefix(self.maxDigits)))
            }
            submitOtp()
        }
    }
    
    func getDigit(at index: Int) -> String? {
        
        if index >= self.otp.count { return nil }
        
        return self.otp.digits[index].numberString
    }
    
    func restartChangePin() {
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.resendRequestAfterClose(self.cardId, .restartChangePin)
            self.action.send(ConfirmViewModelAction.Close.SelfView())
        }
    }
}

private extension String {
    
    var digits: [Int] {
        
        return self.compactMap{ Int(String($0)) }
    }
}

private extension Int {
    
    var numberString: String {
        
        guard self < 10 else { return "0" }
        
        return String(self)
    }
}

enum ConfirmViewModelAction {
    
    enum Close {
        struct SelfView: ComfirmViewAction {}
    }
}

protocol ComfirmViewAction {}

public extension ConfirmViewModel {
    
    enum CVVPinAction {
        case changePin(PhoneDomain.Phone)
        case showCvv
        case changePinResult(ChangePinResult)
        case restartChangePin
    }
    
    enum ChangePinResult {
        case successScreen
        case errorScreen
    }
    
    struct ChangePinStruct {
        public let cardId: CardDomain.CardId
        public let newPin: PinDomain.NewPin
        public let otp: OtpDomain.Otp
    }
}
