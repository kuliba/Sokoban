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
        
        let paymentFlow = info.paymentFlow(info.paymentFlow)
        
        switch paymentFlow {
        case .none:
            guard let paymentsPayload = info.paymentsPayload(activeProductID: activeProductID, getProduct: getProduct)
            else { return nil }
            
            return getPaymentsNavigation(
                from: paymentsPayload,
                closeAction: closeAction
            )
            
        case .mobile:
            return nil
            
        case .qr:
            return nil
            
        case .standard:
            return nil
            
        case .taxAndStateServices:
            return nil
            
        case .transport:
            return nil
        }
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
