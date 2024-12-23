//
//  RootViewModelFactory+getPaymentsNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.12.2024.
//

/// A namespace.
enum PaymentsDomain {}

extension PaymentsDomain {
    
    enum PaymentsPayload: Equatable {
        
        case source(Payments.Operation.Source)
        case service(Payments.Service)
        case mode(PaymentsMeToMeViewModel.Mode)
    }
    
    enum Navigation {
        
        case meToMe(PaymentsMeToMeViewModel)
        case payments(PaymentsViewModel)
    }
    
    enum PaymentFlow {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getPaymentsNavigation(
        from paymentsPayload: PaymentsDomain.PaymentsPayload,
        closeAction: @escaping () -> Void
    ) -> PaymentsDomain.Navigation? {
        
        return getPaymentsNavigation(
            from: paymentsPayload,
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
    func getPaymentsNavigation(
        from paymentsPayload: PaymentsDomain.PaymentsPayload,
        makePaymentsWithSource: @escaping (Payments.Operation.Source) -> PaymentsViewModel?,
        makePaymentsWithService: @escaping (Payments.Service) -> PaymentsViewModel?,
        makeMeToMe: (PaymentsMeToMeViewModel.Mode) -> PaymentsMeToMeViewModel?
    ) -> PaymentsDomain.Navigation? {
        
        switch paymentsPayload {
        case let .mode(mode):
            return makeMeToMe(mode).map { .meToMe($0) }
            
        case let .service(service):
            return makePaymentsWithService(service).map { .payments($0) }
            
        case let .source(source):
            return makePaymentsWithSource(source).map { .payments($0) }
        }
    }
}
