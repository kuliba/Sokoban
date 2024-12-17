//
//  RootViewModelFactory+makeLegacyTemplatePayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeLegacyTemplatePayment(
        payload: (PaymentTemplateData, () -> Void)
    ) -> PaymentsViewModel {
        
        let (template, close) = payload
        
        return PaymentsViewModel(
            source: .template(template.id),
            model: self.model,
            closeAction: close
        )
    }
}
