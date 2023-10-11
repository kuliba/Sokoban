//
//  ConfirmViewModel.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import Foundation
import Combine

public class ConfirmViewModel: ObservableObject {
   
    let maxDigits: Int
    
    @Published var pin: String
    @Published var isDisabled: Bool
    @Published var showAlert: Bool 

    let action: PassthroughSubject<ComfirmViewAction, Never> = .init()

    let phoneNumber: String
    let cardId: Int
    let actionType: CVVPinAction

    let handler: (String, @escaping (String?) -> Void) -> Void
    let showSpinner: () -> Void
    let resendRequestAfterClose: (Int, CVVPinAction) -> Void
    var alertMessage: String = ""
    
    public init(
        phoneNumber: String,
        cardId: Int,
        actionType: CVVPinAction,
        maxDigits: Int = 6,
        pin: String = "",
        isDisable: Bool = false,
        showAlert: Bool = false,
        handler: @escaping (String, @escaping (String?) -> Void) -> Void,
        showSpinner: @escaping () -> Void,
        resendRequestAfterClose: @escaping (Int, CVVPinAction) -> Void
    ) {
        self.phoneNumber = phoneNumber
        self.cardId = cardId
        self.actionType = actionType
        self.maxDigits = maxDigits
        self.pin = pin
        self.isDisabled = isDisable
        self.showAlert = showAlert
        self.handler = handler
        self.showSpinner = showSpinner
        self.resendRequestAfterClose = resendRequestAfterClose
    }

    func submitPin() {
        
        guard !pin.isEmpty else { return }
        
        if pin.count == maxDigits && !isDisabled {
            
            isDisabled = true
            //showSpinner()
            handler(pin) { [weak self] text in
                
                guard let self else { return }
                
                if let message = text {
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let self else { return }

                        self.isDisabled = false
                        self.pin = ""
                        self.alertMessage = message
                        self.showAlert = true
                    }
                } else {
                    self.resendRequestAfterClose(self.cardId, self.actionType)
                    DispatchQueue.main.async { [unowned self] in
                        self.action.send(ConfirmViewModel.Close.SelfView())
                    }
                }
            }
        }
        
        if pin.count > maxDigits {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                self.pin = String(self.pin.prefix(self.maxDigits))
            }
            submitPin()
        }
    }
    
    func getDigit(at index: Int) -> String? {
        
        if index >= self.pin.count { return nil }
        
        return self.pin.digits[index].numberString
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

extension ConfirmViewModel {
    
    enum Close {
        struct SelfView: ComfirmViewAction {}
    }
}

protocol ComfirmViewAction {}

public extension ConfirmViewModel {
    
    enum CVVPinAction {
        case changePin
        case showCvv
    }
}
