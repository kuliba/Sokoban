//
//  RootViewModelFactory+getInfoRepeatPaymentNavigation.swift
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
    func getInfoRepeatPaymentNavigation(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        activeProductID: ProductData.ID,
        closeAction: @escaping () -> Void
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        return getInfoRepeatPaymentNavigation(
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
    func getInfoRepeatPaymentNavigation(
        from paymentsPayload: PaymentsPayload,
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?,
        makePaymentsWithSource: @escaping (Payments.Operation.Source) -> PaymentsViewModel?,
        makePaymentsWithService: @escaping (Payments.Service) -> PaymentsViewModel?,
        makeMeToMe: (PaymentsMeToMeViewModel.Mode) -> PaymentsMeToMeViewModel?
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        switch paymentsPayload {
        case let .mode(mode):
            return makeMeToMe(mode).map { .meToMe($0) }
            
        case let .service(service):
            return makePaymentsWithService(service).map { .payments($0) }
            
        case let .source(source):
            return makePaymentsWithSource(source).map { .payments($0) }
        }
    }
    
    @inlinable
    func getInfoRepeatPaymentNavigation(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?,
        makePaymentsWithSource: @escaping (Payments.Operation.Source) -> PaymentsViewModel?,
        makePaymentsWithService: @escaping (Payments.Service) -> PaymentsViewModel?,
        makeMeToMe: (PaymentsMeToMeViewModel.Mode) -> PaymentsMeToMeViewModel?
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        guard let a = info.paymentsPayload(activeProductID: activeProductID, getProduct: getProduct)
        else { return nil }
        
        return getInfoRepeatPaymentNavigation(from: a, activeProductID: activeProductID, getProduct: getProduct, makePaymentsWithSource: makePaymentsWithSource, makePaymentsWithService: makePaymentsWithService, makeMeToMe: makeMeToMe)
    }
}

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func paymentsPayload(
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsPayload? {
        
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

enum PaymentsPayload: Equatable {
    
    case source(Payments.Operation.Source)
    case service(Payments.Service)
    case mode(PaymentsMeToMeViewModel.Mode)
}
