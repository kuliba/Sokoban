//
//  QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHub

public final class QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, Source> {
    
    private let microServices: MicroServices
    
    public init(microServices: MicroServices) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = QRBinderGetNavigationComposerMicroServices<Payments>
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
            completion(.payments(payments))
            
        default:
            fatalError()
        }
    }
    
    typealias FlowDomain = PayHubUI.FlowDomain<QRResult, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Navigation = QRNavigation<Payments>
}
