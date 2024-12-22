//
//  RootViewModelFactory+getInfoRepeatPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain {
    
    enum Navigation {
        
        case meToMe(PaymentsMeToMeViewModel)
        case payments(PaymentsViewModel)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        activeProductID: ProductData.ID,
        closeAction: @escaping () -> Void
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        return getInfoRepeatPayment(
            from: info,
            activeProductID: activeProductID,
            getProduct: { [weak model] id in
                
                model?.products.value.flatMap(\.value).first { $0.id == id }
            },
            makePaymentsWithSource: { [weak model] source in
                
                model.map {
                    
                    .init(source: source, model: $0, closeAction: closeAction)
                }
            },
            makePaymentsWithService: { [weak model] service in
                
                model.map {
                    
                    .init($0, service: service, closeAction: closeAction)
                }
            },
            makeMeToMe: { [weak model] mode in
                
                guard let model else { return nil }
                
                return .init(model, mode: mode)
            }
        )
    }
    
    @inlinable
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?,
        makePaymentsWithSource: @escaping (Payments.Operation.Source) -> PaymentsViewModel?,
        makePaymentsWithService: @escaping (Payments.Service) -> PaymentsViewModel?,
        makeMeToMe: (PaymentsMeToMeViewModel.Mode) -> PaymentsMeToMeViewModel?
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        if let source = info.source(activeProductID: activeProductID, getProduct: getProduct) {
            
            return makePaymentsWithSource(source).map { .payments($0) }
        }
        
        if let service = info.otherBankService() {
            
            return makePaymentsWithService(service).map { .payments($0) }
        }
        
        if let mode = info.betweenTheirMode(getProduct: getProduct) {
            
            return makeMeToMe(mode).map { .meToMe($0) }
        }
        
        return nil
    }
}
