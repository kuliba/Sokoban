//
//  QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source> {
    
    private let microServices: MicroServices
    private let witnesses: Witnesses
    
    public init(
        microServices: MicroServices,
        witnesses: Witnesses
    ) {
        self.microServices = microServices
        self.witnesses = witnesses
    }
    
    public typealias MicroServices = QRBinderGetNavigationComposerMicroServices<Payments, QRCode, QRFailure>
    public typealias Witnesses = QRBinderGetNavigationWitnesses<Payments>
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
            completion(.qrFailure(qrFailure))
            
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
