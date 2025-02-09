//
//  State.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

public struct State<Confirmation> {
    
    public var isLoading: Bool = false
    public var formResult: LoadFormResult<Confirmation>?
    
    public init(
        isLoading: Bool = false,
        formResult: LoadFormResult<Confirmation>? = nil
    ) {
        self.isLoading = isLoading
        self.formResult = formResult
    }
}

public extension State {
    
    var consent: Bool { form?.consent ?? false }
    
    var form: Form<Confirmation>? {
        
        get {
            
            guard case let .success(form) = formResult
            else { return nil }
            
            return form
        }
        
        set(newValue) {
            
            guard let newValue, case .success = formResult
            else { return }
            
            formResult = .success(newValue)
        }
    }
    
    var hasConfirmation: Bool {
        
        if case .success = form?.confirmation {
            return true
        } else {
            return false
        }
    }
    
    var isValid: Bool { form?.isValid ?? false } // rename to `canOrder`
    
    var payload: OrderCardPayload? {
        
        guard isValid,
              let form,
              let otp = form.otp
        else { return nil }
        
        return .init(
            requestID: form.requestID,
            cardApplicationCardType: form.cardApplicationCardType,
            cardProductExtID: form.cardProductExtID,
            cardProductName: form.cardProductName,
            smsInfo: form.messages.isOn,
            verificationCode: otp
        )
    }
}
