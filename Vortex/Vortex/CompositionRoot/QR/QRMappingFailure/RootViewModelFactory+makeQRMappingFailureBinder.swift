//
//  RootViewModelFactory+makeQRMappingFailureBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeQRMappingFailureBinder(
        qrCode: QRCode?
    ) -> QRMappingFailureDomain.Binder {
        
        return composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation(qrCode: qrCode),
            witnesses: .empty
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: QRMappingFailureDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .back:          return .milliseconds(100)
        case .detailPayment: return .milliseconds(500)
        case .manualSearch:  return .milliseconds(500)
        case .scanQR:        return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        qrCode: QRCode?
    ) -> (
        QRMappingFailureDomain.Select,
        @escaping QRMappingFailureDomain.Notify,
        @escaping (QRMappingFailureDomain.Navigation) -> Void
    ) -> Void {
        
        return { [weak self] select, notify, completion in
            
            guard let self else { return }
            
            switch select {
            case .back:
                completion(.back)
                
            case .detailPayment:
                completion(.detailPayment(
                    makePaymentsNode(
                        payload: .init(qrCode: qrCode),
                        notify: { notify($0.notifyEvent) }
                    )
                ))
                
            case .manualSearch:
                completion(.manualSearch("abc"))
                
            case .scanQR:
                completion(.scanQR)
            }
        }
    }
}

private extension PaymentsViewModel.Payload {
    
    init(qrCode: QRCode?) {
        
        self = qrCode.map { .source(.requisites(qrCode: $0)) } ?? .service(.requisites)
    }
}

private extension RootViewModelFactory.PaymentsViewModelEvent {
    
    var notifyEvent: QRMappingFailureDomain.NotifyEvent {
        
        switch self {
        case .close: return .dismiss
        case .scanQR: return .select(.scanQR)
        }
    }
}
