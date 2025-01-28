//
//  RootViewModelFactory+makeQRMappingFailureBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

import FlowCore
import PayHubUI

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
        case .detailPayment:  return .milliseconds(500)
        case .categoryPicker: return .milliseconds(500)
        case .outside:        return .milliseconds(100)
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
            case .detailPayment:
                completion(.detailPayment(
                    makePaymentsNode(
                        payload: .init(qrCode: qrCode),
                        notify: { notify($0.notifyEvent) }
                    )
                ))
                
            case .manualSearch:
                completion(.categoryPicker(
                    makeCategoryPicker().asNode(
                        transform: { $0.outcome },
                        notify: notify
                    )
                ))

            case let .outside(outside):
                completion(.outside(outside))
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

// MARK: - Adapters

private extension PaymentsViewModel.Payload {
    
    init(qrCode: QRCode?) {
        
        self = qrCode.map { .source(.requisites(qrCode: $0)) } ?? .service(.requisites)
    }
}

private extension RootViewModelFactory.PaymentsViewModelEvent {
    
    var notifyEvent: QRMappingFailureDomain.NotifyEvent {
        
        switch self {
        case .close: return .dismiss
        case .scanQR: return .select(.outside(.scanQR))
        }
    }
}

private extension CategoryPickerViewDomain.Navigation {
    
    var outcome: NavigationOutcome<QRMappingFailureDomain.Select>? {
        
        switch self {
        case .destination, .failure:
            return nil
            
        case let .outside(outside):
            switch outside {
            case .main: return .select(.outside(.main))
            case .qr:   return .select(.outside(.scanQR))
            }
        }
    }
}
