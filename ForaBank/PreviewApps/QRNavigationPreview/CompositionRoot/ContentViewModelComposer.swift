//
//  ContentViewModelComposer.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 05.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class ContentViewModelComposer {
    
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        interactiveScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.mainScheduler = mainScheduler
        self.interactiveScheduler = interactiveScheduler
    }
}

extension ContentViewModelComposer {
    
    func compose() -> ContentViewDomain.Flow {
        
        let qrComposer = makeQRBinderComposer()
        
        let composer = ContentViewDomain.Composer(
            getNavigation: { select, notify, completion in
                
                switch select {
                case .scanQR:
                    let qr = qrComposer.compose()
                    let close = qr.content.isClosedPublisher
                        .sink { if $0 { notify(.dismiss) }}
                    
                    completion(.qr(.init(model: qr, cancellable: close)))
                }
            },
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose()
    }
}

private extension ContentViewModelComposer {
    
    func makeWitnesses() -> QRDomain.Witnesses {
        
        return .init(
            contentEmitting: { $0.publisher },
            contentReceiving: { content in { content.receive() }},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
    }
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, Source>
    
    func makeNavigationComposer() -> NavigationComposer {
        
        return .init(
            microServices: .init(
                makePayments: {
                    
                    switch $0 {
                    case let .c2bSubscribe(url):
                        Payments(url: url)
                    }
                }
            ),
            witnesses: .init(
                isClosed: { $0.isClosedPublisher }
            )
        )
    }
    
    typealias QRBinderComposer = PayHubUI.QRBinderComposer<QRNavigation, QRModel, QRResult>
    
    func makeQRBinderComposer() -> QRBinderComposer {
        
        let factory = ContentFlowBindingFactory(scheduler: mainScheduler)
        let witnesses = makeWitnesses()
        let composer = makeNavigationComposer()
        
        return .init(
            microServices: .init(
                bind: factory.bind(with: witnesses),
                getNavigation: composer.getNavigation,
                makeQR: QRModel.init
            ),
            mainScheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
    }
}
