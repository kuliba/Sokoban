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
        
        let composer = ContentViewDomain.Composer(
            getNavigation: getNavigation,
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return composer.compose()
    }
}

private extension ContentViewModelComposer {
    
    func getNavigation(
        select: ContentViewSelect,
        using notify: @escaping (ContentViewDomain.NotifyEvent) -> Void,
        completion: @escaping (ContentViewNavigation) -> Void
    ) {
        let qrComposer = makeQRBinderComposer()
        
        switch select {
        case .scanQR:
            let qr = qrComposer.compose()
            
            completion(.qr(.init(
                model: qr,
                cancellables: bind(qr: qr, using: notify)
            )))
        }
    }
    
    func bind(
        qr: QRDomain.Binder,
        using notify: @escaping (ContentViewDomain.NotifyEvent) -> Void
    ) -> Set<AnyCancellable> {
        
        let addCompany = qr.flow.$state
            .compactMap(\.navigation)
            .compactMap {
                
                switch $0 {
                case let .outside(outside):
                    return outside
                    
                default:
                    return nil
                }
            }
            .sink {
                
                switch $0 {
                case .chat:
                    print("Need to switch to chat tab")
                    notify(.dismiss)
                    
                case .main:
                    print("Need to switch to main tab")
                    notify(.dismiss)
                    
                case .payments:
                    print("Need to switch to payments tab")
                    notify(.dismiss)
                }
            }
        
        let close = qr.content.isClosedPublisher
            .sink { if $0 { notify(.dismiss) }}
        
        return [addCompany, close]
    }
    
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
    
    private typealias NavigationComposer = QRBinderGetNavigationComposer<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailureDomain.Binder, Source, ServicePicker>
    
    private func makeNavigationComposer() -> NavigationComposer {
        
        return .init(
            microServices: .init(
                makeMixedPicker: { _ in .init() },
                makeMultiplePicker: { _ in .init() },
                makePayments: makePayments,
                makeQRFailure: qrFailureBinderComposer.compose,
                makeServicePicker: { _ in .init() }
            ),
            witnesses: .init(
                addCompany: .init(
                    mixedPicker: { $0.addCompanyPublisher },
                    multiplePicker: { $0.addCompanyPublisher },
                    servicePicker: { $0.publisher(for: \.goToChat) }
                ),
                goToMain: .init(
                    servicePicker: { $0.publisher(for: \.goToMain) }
                ),
                goToPayments: .init(
                    servicePicker: { $0.publisher(for: \.goToPayments) }
                ),
                isClosed: .init(
                    mixedPicker: { $0.isClosedPublisher },
                    multiplePicker: { $0.isClosedPublisher },
                    payments: { $0.isClosedPublisher },
                    qrFailure: { _ in Empty().eraseToAnyPublisher() },
                    servicePicker: { _ in fatalError() }
                ),
                scanQR: .init(
                    mixedPicker: { $0.scanQRPublisher },
                    multiplePicker: { $0.scanQRPublisher },
                    payments: { $0.scanQRPublisher },
                    qrFailure: { _ in Empty().eraseToAnyPublisher() },
                    servicePicker: { $0.publisher(for: \.scanQR) }
                )
            )
        )
    }
    
    private func makePayments(
        payload: NavigationComposer.MicroServices.MakePaymentsPayload
    ) -> Payments {
        
        switch payload {
        case let .c2bSubscribe(url), let .c2b(url):
            return .init(url: url)
            
        case let .details(qrCode):
            return .init(source: .details(qrCode))
        }
    }
}

extension QRFailureDomain.Navigation {
    
    var scanQR: Void? {
        
        guard case .scanQR = self else { return nil }
        
        return ()
    }
}
