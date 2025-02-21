//
//  ProductState.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

public enum Loadable<ProductState> {
    
    /// `nil` represents clean state, `some` - previously loaded.
    case loading(ProductState?)
    
    /// `nil` represents idle state, `some` - loaded result.
    case loaded(Loaded?)
    
    public typealias Loaded = Result<ProductState, LoadFailure>
}

public extension Loadable {
    
    var isLoading: Bool {
        
        guard case .loading = self else { return false }
        
        return true
    }
    
    var state: ProductState? {
        
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

public struct ProductState<Confirmation> {
    
    public var loadableForm: Loadable<Form<Confirmation>>
    
    public init(
        loadableForm: Loadable<Form<Confirmation>>
    ) {
        self.loadableForm = loadableForm
    }
}

public extension ProductState {
        
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
    
    var payload: OrderAccountPayload? {
        
        guard isValid,
              let form,
              let otp = form.otp
        else { return nil }
        
        return .init(
            amount: form.amount,
            cryptoVersion: "1.0",
            currencyCode: form.currency.code, sourceAccountId: form.sourceAccountId, sourceCardId: form.sourceCardId, verificationCode: otp
        )
    }
}

private extension Form {
    
    var isValid: Bool {
        
        switch confirmation {
        case .loaded(nil):
            return true
            
        default: // rename to `canOrder`
            return otp?.count == 6 && consent
        }
    }
}
