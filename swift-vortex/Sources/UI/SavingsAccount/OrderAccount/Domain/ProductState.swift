//
//  ProductState.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import LoadableState
import PaymentComponents

public struct ProductState<Confirmation> {
    
    public var loadableForm: Loadable<Form<Confirmation>>
    public var productSelect: ProductSelect

    public init(
        loadableForm: Loadable<Form<Confirmation>>,
        productSelect: ProductSelect = .init(selected: nil)
    ) {
        self.loadableForm = loadableForm
        self.productSelect = productSelect
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
    
    var payload: ProductEffect.OrderAccountPayload? {
        
        guard isValid,
              let form,
              let otp = form.otp
        else { return nil }
        
        return .init(
            amount: Double(form.amount?.description ?? "0"),
            cryptoVersion: "1.0",
            currencyCode: form.constants.currency.code, 
            sourceAccountId: form.sourceAccountId,
            sourceCardId: form.sourceCardId,
            verificationCode: otp
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
