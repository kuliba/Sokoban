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
    public typealias Witnesses = QRBinderGetNavigationWitnesses<Payments, QRFailure>
}

public extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        qrResult: QRResult,
        notify: @escaping Notify,
        completion: @escaping (Navigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            let payments = microServices.makePayments(.c2bSubscribe(url))
            completion(.payments(.init(
                model: payments,
                cancellables: bind(payments, with: notify)
            )))
            
        case let .c2bURL(url):
            let payments = microServices.makePayments(.c2b(url))
            completion(.payments(.init(
                model: payments,
                cancellables: bind(payments, with: notify)
            )))
            
        case let .failure(qrCode):
            let qrFailure = microServices.makeQRFailure(qrCode)
            completion(.qrFailure(.init(
                model: qrFailure,
                cancellables: bind(qrFailure, with: notify)
            )))
            
        case let .mapped(mapped):
            getNavigation(mapped, notify, completion)
            
        default:
            fatalError()
        }
    }
    
    typealias FlowDomain = PayHubUI.FlowDomain<QRResult, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Navigation = QRNavigation<Payments, QRFailure>
}

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        _ mapped: QRResult.Mapped,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch mapped {
        case let .mixed(mixed, qrCode, QRMapping):
            let _ /*mixedPicker*/ = microServices.makeMixedPicker((mixed, qrCode, QRMapping))
            
        default:
            fatalError()
        }
    }
}

// MARK: - bindings

private extension QRBinderGetNavigationComposer {
    
    func bind(
        _ qrFailure: QRFailure,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let scanQR = witnesses.qrFailureScanQR(qrFailure)
            .sink { notify(.dismiss) }
        
        return [scanQR]
    }
    
    func bind(
        _ payments: Payments,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.isClosed(payments)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR(payments)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
}
