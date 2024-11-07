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
    
    private let qrFailureBinderComposer: QRFailureBinderComposer
    
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        interactiveScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.mainScheduler = mainScheduler
        self.interactiveScheduler = interactiveScheduler
        
        self.qrFailureBinderComposer = .init(
            delay: .milliseconds(100),
            microServices: .init(
                makeCategories: Categories.init(qrCode:),
                makeDetailPayment: Payments.init(qrCode:),
                makeQRFailure: QRFailure.init(qrCode:)
            ),
            scanQRWitnesses: .init(
                categories: { $0.scanQRPublisher },
                detailPayment: { $0.scanQRPublisher }
            ),
            witnesses: .init(
                contentEmitting: { $0.selectPublisher },
                contentReceiving: { $0.receive },
                flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                flowReceiving: { flow in { flow.event(.select($0)) }}
            ),
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
    }
    
    typealias QRFailureBinderComposer = PayHubUI.QRFailureBinderComposer<QRCode, QRFailure, Categories, Payments>
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
    
    private func makeWitnesses() -> QRDomain.Witnesses {
        
        return .init(
            contentEmitting: { $0.publisher },
            contentReceiving: { content in { content.receive() }},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
    }
    
    private typealias NavigationComposer = QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, QRFailureDomain.Binder, Source>
    
    private func makeNavigationComposer() -> NavigationComposer {
        
        return .init(
            microServices: .init(
                makeQRFailure: qrFailureBinderComposer.compose(qrCode:),
                makePayments: makePayments
            ),
            witnesses: .init(
                isClosed: { $0.isClosedPublisher },
                scanQR: { $0.scanQRPublisher },
                qrFailureScanQR: { $0.flow.$state.compactMap(\.navigation?.scanQR).eraseToAnyPublisher() }
            )
        )
    }
    
    private func makePayments(
        payload: NavigationComposer.MicroServices.MakePaymentsPayload
    ) -> Payments {
        
        switch payload {
        case let .c2bSubscribe(url),
            let .c2b(url):
            return Payments(url: url)
        }
    }
}

extension QRFailureDomain.Navigation {
    
    var scanQR: Void? {
        
        guard case .scanQR = self else { return nil }
        
        return ()
    }
}
