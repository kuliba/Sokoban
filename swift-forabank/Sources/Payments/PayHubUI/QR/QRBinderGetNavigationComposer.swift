//
//  QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class QRBinderGetNavigationComposer<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source> {
    
    private let microServices: MicroServices
    private let witnesses: Witnesses
    
    public init(
        microServices: MicroServices,
        witnesses: Witnesses
    ) {
        self.microServices = microServices
        self.witnesses = witnesses
    }
    
    public typealias MicroServices = QRBinderGetNavigationComposerMicroServices<MixedPicker, Operator, Payments, Provider, QRCode, QRMapping, QRFailure>
    public typealias Witnesses = QRBinderGetNavigationWitnesses<MixedPicker, Payments, QRFailure>
}

public extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        select: Select,
        notify: @escaping Notify,
        completion: @escaping (Navigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            getNavigation(outside, notify, completion)
            
        case let .qrResult(qrResult):
            getNavigation(qrResult, notify, completion)
        }
    }
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
        
    enum Select {
        
        case outside(Outside)
        case qrResult(QRResult)
        
        public enum Outside {
            
            case chat
        }

        public typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    }
    
    enum Navigation {
        
        case outside(Outside)
        case qrNavigation(QRNavigation)
        
        public enum Outside {
            
            case chat
        }
        
        public typealias QRNavigation = PayHubUI.QRNavigation<MixedPicker, Payments, QRFailure>
    }
}

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        _ outside: Select.Outside,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch outside {
        case .chat:
            fatalError()
            completion(.outside(.chat))
        }
    }
    
    func getNavigation(
        _ qrResult: Select.QRResult,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            let payments = microServices.makePayments(.c2bSubscribe(url))
            completion(.qrNavigation(.payments(.init(
                model: payments,
                cancellables: bind(payments, using: notify)
            ))))
            
        case let .c2bURL(url):
            let payments = microServices.makePayments(.c2b(url))
            completion(.qrNavigation(.payments(.init(
                model: payments,
                cancellables: bind(payments, using: notify)
            ))))
            
        case let .failure(qrCode):
            let qrFailure = microServices.makeQRFailure(.qrCode(qrCode))
            completion(.qrNavigation(.qrFailure(.init(
                model: qrFailure,
                cancellables: bind(qrFailure, using: notify)
            ))))
            
        case let .mapped(mapped):
            getNavigation(mapped, notify, completion)
            
        default:
            fatalError()
        }
    }
    
    func getNavigation(
        _ mapped: Select.QRResult.Mapped,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch mapped {
        case let .missingINN(qrCode):
            let qrFailure = microServices.makeQRFailure(.missingINN(qrCode))
            completion(.qrNavigation(.qrFailure(.init(
                model: qrFailure,
                cancellables: bind(qrFailure, using: notify)
            ))))
            
        case let .mixed(mixed):
            let mixedPicker = microServices.makeMixedPicker(mixed)
            completion(.qrNavigation(.mixedPicker(.init(
                model: mixedPicker,
                cancellables: bind(mixedPicker, using: notify)
            ))))
            
        default:
            fatalError()
        }
    }
}

// MARK: - bindings

private extension QRBinderGetNavigationComposer {
    
    func bind(
        _ mixedPicker: MixedPicker,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.mixedPicker.isClosed(mixedPicker)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.mixedPicker.scanQR(mixedPicker)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
    
    func bind(
        _ qrFailure: QRFailure,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.qrFailure.isClosed(qrFailure)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.qrFailure.scanQR(qrFailure)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
    
    func bind(
        _ payments: Payments,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.payments.isClosed(payments)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.payments.scanQR(payments)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
}
