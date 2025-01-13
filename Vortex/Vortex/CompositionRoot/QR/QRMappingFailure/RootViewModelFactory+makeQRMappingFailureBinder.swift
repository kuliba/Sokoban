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
        case .categoryPicker:  return .milliseconds(500)
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
                completion(.categoryPicker(
                    makeCategoryPickerSection(.init(
                        loadCategories: getServiceCategoriesWithoutQR,
                        reloadCategories: { $0(nil) },
                        loadAllLatest: { $0(nil) }
                    ))
                ))
                
            case .scanQR:
                completion(.scanQR)
            }
        }
    }
    
    @inlinable
    func getServiceCategoriesWithoutQR(
        completion: @escaping ([ServiceCategory]) -> Void
    ) {
        // TODO: replace with reading from ephemeral store
        getServiceCategories {
            
            completion($0.filter { $0.paymentFlow != .qr })
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
