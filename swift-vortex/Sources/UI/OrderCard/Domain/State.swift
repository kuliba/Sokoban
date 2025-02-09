//
//  State.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

public enum Loadable<State> {
    
    /// `nil` represents clean state, `some` - previously loaded.
    case loading(State?)
    
    /// `nil` represents idle state, `some` - loaded result.
    case loaded(Loaded?)
    
    public typealias Loaded = Result<State, LoadFailure>
}

public extension Loadable {
    
    var isLoading: Bool {
        
        guard case .loading = self else { return false }
        
        return true
    }
    
    var state: State? {
        
        get {
            
            guard case let .loaded(.success(state)) = self
            else { return nil }
            
            return state
        }
        
        set(newValue) {
            
            guard let newValue, case .loaded(.success) = self
            else { return }
            
            self = .loaded(.success(newValue))
        }
    }
}

public struct State<Confirmation> {
    
    public var loadableForm: Loadable<Form<Confirmation>>
    
    public init(
        loadableForm: Loadable<Form<Confirmation>>
    ) {
        self.loadableForm = loadableForm
    }
}

public extension State {
    
//    var isProductLoading: Bool { isLoading && form == nil }
    
//    var consent: Bool { form?.consent ?? false }
    
    /// active form
    var form: Form<Confirmation>? {
        
        get {
            
            guard let form = loadableForm.state else { return nil }
            
            return form
        }
        
        set(newValue) {
            
            guard let newValue, case .loaded(.success) = loadableForm
            else { return }
            
            loadableForm = .loaded(.success(newValue))
        }
    }
    
    var hasConfirmation: Bool {
        
        loadableForm.state?.confirmation.state != nil
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
