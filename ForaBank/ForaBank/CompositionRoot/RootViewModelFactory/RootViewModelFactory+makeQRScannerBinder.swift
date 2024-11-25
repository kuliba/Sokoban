//
//  RootViewModelFactory+makeQRScannerBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import Combine
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makeQRScannerBinder() -> QRScannerDomain.Binder {
        
        return compose(getNavigation: getQRNavigation, makeContent: makeQRScannerModel, witnesses: .default)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getQRNavigation(
        select: QRScannerDomain.Select,
        notify: @escaping QRScannerDomain.Notify,
        completion: @escaping (QRScannerDomain.Navigation) -> Void
    ) {
        // TODO: - replace using QRBinderGetNavigationComposer
        
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .qrResult(qrResult):
            getQRNavigation(qrResult, notify, completion)
        }
    }
    
    @inlinable
    func getQRNavigation(
        _ qrResult: QRModelResult,
        _ notify: @escaping QRScannerDomain.Notify,
        _ completion: @escaping (QRScannerDomain.Navigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            completion(payments(payload: .source(.c2bSubscribe(url))))
            
        case let .c2bURL(url):
            completion(payments(payload: .source(.c2b(url))))
            
        case let .failure(qrCode):
            completion(.failure(makeQRFailure(qrCode: qrCode)))
            
        case let .mapped(mapped):
            getQRNavigation(mapped, notify, completion)
            
        default:
            break
        }
        
        func payments(
            payload: PaymentsViewModel.Payload
        ) -> QRScannerDomain.Navigation {
            
            return .payments(makePaymentsNode(
                payload: payload,
                notify: { notify($0.notifyEvent) }
            ))
        }
    }
    
    @inlinable
    func getQRNavigation(
        _ mapped: QRMappedResult,
        _ notify: @escaping QRScannerDomain.Notify,
        _ completion: @escaping (QRScannerDomain.Navigation) -> Void
    ) {
        switch mapped {
        case let .missingINN(qrCode):
            completion(.failure(makeQRFailure(qrCode: qrCode)))
            
        case let .mixed(mixed):
            completion(providerPicker(mixed))
            
        case let .multiple(multiple):
            completion(operatorSearch(multiple))
            
        default:
            break
        }
        
        func operatorSearch(
            _ multiple: MultipleQRResult
        ) -> QRScannerDomain.Navigation {
            
            let operatorSearch = makeOperatorSearch(
                multiple: multiple,
                notify: { _ in }
            )
            
            return .operatorSearch(operatorSearch)
        }
        
        func providerPicker(
            _ mixed: QRMappedResult.Mixed
        ) -> QRScannerDomain.Navigation {
            
            let node = makeProviderPickerNode(
                multi: mixed.operators,
                qrCode: mixed.qrCode,
                qrMapping: mixed.qrMapping,
                notify: { notify(.init($0)) }
            )
            
            return .providerPicker(node)
        }
    }
}

// MARK: - Adapters

private extension ContentWitnesses
where Content == QRScannerModel,
      Select == QRScannerDomain.Select {
    
    static var `default`: Self {
        
        return .init(
            emitting: { $0.selectPublisher },
            receiving: { content in { content.event(.reset) }}
        )
    }
}

private extension QRScannerModel {
    
    var selectPublisher: AnyPublisher<QRScannerDomain.Select, Never> {
        
        $state
            .compactMap(\.?.qrResult)
            .map(QRScannerDomain.Select.qrResult)
            .eraseToAnyPublisher()
    }
}

private extension QRModelWrapperState {
    
    var qrResult: QRResult? {
        
        guard case let .qrResult(qrResult) = self else { return nil }
        
        return qrResult
    }
}

private extension RootViewModelFactory.PaymentsViewModelEvent {
    
    var notifyEvent: QRScannerDomain.NotifyEvent {
        
        switch self {
        case .close:  return .dismiss
        case .scanQR: return .dismiss
        }
    }
}

private extension QRScannerDomain.NotifyEvent {
    
    typealias PickerFlowEvent = PayHub.FlowEvent<SegmentedPaymentProviderPickerFlowModel.State.Status.Outside, Never>
    
    init(_ event: PickerFlowEvent) {
        
        switch event {
        case .dismiss:
            self = .dismiss
            
        case let .select(select):
            switch select {
            case .addCompany:
                self = .select(.outside(.chat))
                
            case .main:
                self = .select(.outside(.main))
                
            case .payments:
                self = .select(.outside(.payments))
                
            case .scanQR:
                self = .dismiss
            }
        }
    }
}
