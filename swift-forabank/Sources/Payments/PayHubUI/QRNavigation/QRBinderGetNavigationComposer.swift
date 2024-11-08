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
    
    typealias Domain = QRNavigationDomain<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source>
    typealias FlowDomain = Domain.FlowDomain
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    typealias Select = Domain.Select
    typealias Navigation = Domain.Navigation
}

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        _ outside: Select.Outside,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch outside {
        case .chat:
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
        
        let addCompany = witnesses.addCompany.mixedPicker(mixedPicker)
            .sink { notify(.select(.outside(.chat))) }
        
        let close = witnesses.isClosed.mixedPicker(mixedPicker)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR.mixedPicker(mixedPicker)
            .sink { notify(.dismiss) }
        
        return [addCompany, close, scanQR]
    }
    
    func bind(
        _ qrFailure: QRFailure,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.isClosed.qrFailure(qrFailure)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR.qrFailure(qrFailure)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
    
    func bind(
        _ payments: Payments,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.isClosed.payments(payments)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR.payments(payments)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
}
