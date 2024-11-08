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
    
    private let schedulers: Schedulers
    
    init(
        schedulers: Schedulers = .init()
    ) {
        self.schedulers = schedulers
        
        self.qrFailureBinderComposer = .init(
            delay: .milliseconds(100),
            microServices: .init(
                makeCategoryPicker: CategoryPicker.init(qrCode:),
                makeDetailPayment: Payments.init(qrCode:),
                makeQRFailure: QRFailure.init(with:)
            ),
            contentFlowWitnesses: .init(
                contentEmitting: { $0.selectPublisher },
                contentReceiving: { $0.receive },
                flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                flowReceiving: { flow in { flow.event(.select($0)) }}
            ),
            isClosedWitnesses: .init(
                categoryPicker: { $0.isClosedPublisher },
                detailPayment: { $0.isClosedPublisher }
            ),
            scanQRWitnesses: .init(
                categoryPicker: { $0.scanQRPublisher },
                detailPayment: { $0.scanQRPublisher }
            ),
            schedulers: schedulers
        )
    }
    
    typealias QRFailureBinderComposer = PayHubUI.QRFailureBinderComposer<QRCode, QRFailure, CategoryPicker, Payments>
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
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return composer.compose()
    }
}

private extension ContentViewModelComposer {
    
    typealias Domain = QRNavigationDomain
    typealias QRBinderComposer = PayHubUI.QRBinderComposer<Domain.Navigation, QRModel, Domain.Select>
    
    func makeQRBinderComposer() -> QRBinderComposer {
        
        let factory = ContentFlowBindingFactory(scheduler: schedulers.main)
        let witnesses = makeWitnesses()
        let composer = makeNavigationComposer()
        
        return .init(
            microServices: .init(
                bind: factory.bind(with: witnesses),
                getNavigation: composer.getNavigation,
                makeQR: QRModel.init
            ),
            mainScheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
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
    
    private typealias NavigationComposer = QRBinderGetNavigationComposer<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailureDomain.Binder, Source>
    
    private func makeNavigationComposer() -> NavigationComposer {
        
        return .init(
            microServices: .init(
                makeQRFailure: qrFailureBinderComposer.compose,
                makePayments: makePayments,
                makeMixedPicker: { _ in .init() }
            ),
            witnesses: .init(
                mixedPicker: .init(
                    isClosed: { $0.isClosedPublisher },
                    scanQR: { $0.scanQRPublisher }
                ),
                payments: .init(
                    isClosed: { $0.isClosedPublisher },
                    scanQR: { $0.scanQRPublisher }
                ),
                qrFailure: .init(
                    isClosed: { _ in Empty().eraseToAnyPublisher() },
                    scanQR: { $0.flow.$state.compactMap(\.navigation?.scanQR).eraseToAnyPublisher() }
                )
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
