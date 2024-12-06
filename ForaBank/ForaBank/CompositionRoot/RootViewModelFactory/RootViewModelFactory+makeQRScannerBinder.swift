//
//  RootViewModelFactory+makeQRScannerBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.11.2024.
//

import Combine
import Foundation
import PayHub
import PayHubUI
import SberQR

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
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .qrResult(qrResult):
            getQRNavigation(qrResult, notify, completion)
            
        case .sberQR(nil):
            completion(.sberQR(nil))
            
        case let .sberQR(response):
            #warning("FIXME")
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
            
        case let .sberQR(url):
            makeSberQRConfirmPaymentViewModel(url: url, pay: pay(url)) {
                
                completion(.sberQR($0))
            }
            
        case .url, .unknown:
            completion(.failure(makeQRFailure(qrCode: nil)))
        }
        
        func payments(
            payload: PaymentsViewModel.Payload
        ) -> QRScannerDomain.Navigation {
            
            return .payments(makePaymentsNode(
                payload: payload,
                notify: { notify($0.notifyEvent) }
            ))
        }
        
        func pay(
            _ url: URL
        ) -> (SberQRConfirmPaymentState) -> Void {
           
            decoratedSberQRPay(url) { notify(.select(.sberQR($0))) }
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
            
        case let .none(qrCode):
            completion(payments(payload: .source(.requisites(qrCode: qrCode))))
            
        case let .provider(payload):
            completion(providerServicePicker(payload))
            
        case let .single(single):
            completion(operatorView(single))
            
        case let .source(source):
            completion(payments(payload: .source(source)))
        }
        
        func operatorSearch(
            _ multiple: MultipleQRResult
        ) -> QRScannerDomain.Navigation {
            
            let operatorSearch = makeOperatorSearch(
                multiple: multiple,
                notify: {
                    
                    switch $0 {
                    case .addCompany:
                        notify(.select(.outside(.chat)))
                        
                    case .detailPayment:
#warning("FIXME")
                        break // notify(.select(???))
                        
                    case .dismiss:
                        notify(.dismiss)
                    }
                }
            )
            
            return .operatorSearch(operatorSearch)
        }
        
        func operatorView(
            _ single: SinglePayload
        ) -> QRScannerDomain.Navigation {
            
            let viewModel = InternetTVDetailsViewModel(
                model: model,
                qrCode: single.qrCode,
                mapping: single.qrMapping
            )
            
            return .operatorView(viewModel)
        }
        
        func payments(
            payload: PaymentsViewModel.Payload
        ) -> QRScannerDomain.Navigation {
            
            return .payments(makePaymentsNode(
                payload: payload,
                notify: { notify($0.notifyEvent) }
            ))
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
        
        func providerServicePicker(
            _ payload: ProviderPayload
        ) -> QRScannerDomain.Navigation {
            
            let picker = makeAnywayServicePickerFlowModel(payload: payload)
            
            return .providerServicePicker(picker)
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
            dismissing: { content in { content.event(.reset) }}
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
