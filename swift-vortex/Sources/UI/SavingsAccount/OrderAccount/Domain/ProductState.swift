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
    public var needGoToMain: Bool

    public init(
        loadableForm: Loadable<Form<Confirmation>>,
        needGoToMain: Bool = false,
        productSelect: ProductSelect = .init(selected: nil)
    ) {
        self.loadableForm = loadableForm
        self.productSelect = productSelect
        self.needGoToMain = needGoToMain
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
        
        if form.amountValue ?? 0 > 0, let product = productSelect.selected {
            
            let sourceAccountID: Int? = (product.type == .account) ? product.id.rawValue : nil
            let sourceCardID: Int? = (product.type == .card) ? product.id.rawValue : nil

            return .init(
                amount: Double(form.amountValue?.description ?? "0"),
                cryptoVersion: "1.0",
                currencyCode: form.constants.currency.code,
                sourceAccountId: sourceAccountID,
                sourceCardId: sourceCardID,
                verificationCode: otp
            )
        } else {
            
            return .init(
                amount: nil,
                cryptoVersion: "1.0",
                currencyCode: nil,
                sourceAccountId: nil,
                sourceCardId: nil,
                verificationCode: otp
            )
        }
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
