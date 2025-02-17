//
//  RootViewModelFactory+makeQRScannerBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.11.2024.
//

import Combine
import FlowCore
import Foundation
import PayHub
import PayHubUI
import SberQR

extension RootViewModelFactory {
    
    @inlinable
    func makeQRScannerBinder(
        c2gFlag: C2GFlag
    ) -> QRScannerDomain.Binder {
        
        return composeBinder(
            content: makeQRScannerModel(c2gFlag: c2gFlag),
            delayProvider: delayProvider,
            getNavigation: getQRNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func delayProvider(
        navigation: QRScannerDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .failure:               return settings.delay
        case .operatorSearch:        return settings.delay
        case .operatorView:          return settings.delay
        case .outside:               return .zero
        case .payments:              return settings.delay
        case .providerPicker:        return settings.delay
        case .providerServicePicker: return settings.delay
        case .sberQR:                return .milliseconds(300)
        case .sberQRComplete:        return .milliseconds(300)
        case .searchByUIN:           return .milliseconds(300)
        }
    }
    
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
            
        case .sberQRResponse(nil):
            completion(.sberQR(nil))
            
        case let .sberQRResponse(response):
            let viewModel: PaymentsSuccessViewModel? = response.map { PaymentsSuccessViewModel(paymentSuccess: $0.success, self.model) }
            completion(.sberQRComplete(viewModel))
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
            completion(.failure(
                makeQRMappingFailureNode(qrCode, notify)
            ))
            
        case let .mapped(mapped):
            getQRNavigation(mapped, notify, completion)
            
        case let .sberQR(url):
            makeSberQRConfirmPaymentViewModel(url: url, pay: pay(url)) {
                
                completion(.sberQR($0))
            }
            
        case let .uin(uin):
            completion(.searchByUIN(makeSearchByUIN(uin: uin)))
            
        case .url, .unknown:
            completion(.failure(
                makeQRMappingFailureNode(nil, notify)
            ))
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
            
            decoratedSberQRPay(url) { notify(.select(.sberQRResponse($0))) }
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
            completion(.failure(
                makeQRMappingFailureNode(qrCode, notify)
            ))
            
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
    
    @inlinable
    func makeQRMappingFailureNode(
        _ qrCode: QRCode?,
        _ notify: @escaping QRScannerDomain.Notify
    ) -> Node<QRMappingFailureDomain.Binder> {
        
        makeQRMappingFailureBinder(qrCode: qrCode)
            .asNode(
                transform: { $0.notifyEvent },
                notify: notify
            )
    }

    @inlinable
    func emitting(
        content: QRScannerModel
    ) -> some Publisher<FlowEvent<QRScannerDomain.Select, Never>, Never> {
        
        content.$state
            .compactMap(\.?.qrResult)
            .map(QRScannerDomain.Select.qrResult)
            .map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: QRScannerModel
    ) -> () -> Void {
        
        return { content.event(.reset) }
    }
}

// MARK: - Adapters

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

private extension QRMappingFailureDomain.Navigation {
    
    var notifyEvent: NavigationOutcome<QRScannerDomain.Select>? {
        
        switch self {
        case .detailPayment, .categoryPicker:
            return nil
            
        case let .outside(outside):
            switch outside {
            case .back:     return .dismiss
            case .chat:     return .select(.outside(.chat))
            case .main:     return .select(.outside(.main))
            case .payments: return .select(.outside(.payments))
            case .scanQR:   return .dismiss
            }
        }
    }
}

private extension QRScannerDomain.NotifyEvent {
    
    typealias PickerFlowEvent = Vortex.FlowEvent<SegmentedPaymentProviderPickerFlowModel.State.Navigation.Outside, Never>
    
    init(_ event: PickerFlowEvent) {
        
        switch event {
        case .dismiss:
            self = .dismiss
            
        case let .isLoading(isLoading):
            self = .isLoading(isLoading)
            
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
