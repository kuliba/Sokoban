//
//  RootViewModelFactory+getInfoRepeatPaymentNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension RootViewModelFactory {
    
    @inlinable
    func getInfoRepeatPaymentNavigation(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?,
        closeAction: @escaping () -> Void
    ) -> PaymentsDomain.Navigation? {
        
        guard let paymentsPayload = info.paymentsPayload(activeProductID: activeProductID, getProduct: getProduct)
        else { return nil }
        
        return getPaymentsNavigation(
            from: paymentsPayload,
            closeAction: closeAction
        )
    }
}

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func paymentsPayload(
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsDomain.PaymentsPayload? {
        
        if let source = source(activeProductID: activeProductID, getProduct: getProduct) {
            
            return .source(source)
        }
        
        if let service = otherBankService() {
            
            return .service(service)
        }
        
        if let mode = betweenTheirMode(getProduct: getProduct) {
            
            return .mode(mode)
        }
        
        return nil
    }
}
