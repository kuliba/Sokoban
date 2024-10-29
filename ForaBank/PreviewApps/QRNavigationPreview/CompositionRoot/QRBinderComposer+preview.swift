//
//  QRBinderComposer+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import CombineSchedulers
import Foundation
import PayHubUI

extension QRBinderComposer {
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, Source>

    typealias Composer = QRBinderComposer<QRNavigation, QRModel, QRNavigationPreview.QRResult>
    
    static var preview: Composer {
        
        let mainScheduler: AnySchedulerOf<DispatchQueue> = .immediate
        let interactiveScheduler: AnySchedulerOf<DispatchQueue> = .immediate
        
        let factory = ContentFlowBindingFactory(scheduler: mainScheduler)
        let witnesses = QRDomain.Witnesses(
            contentEmitting: { $0.publisher },
            contentReceiving: { content in { content.receive() }},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
        
        let getNavigationComposer = NavigationComposer(
            microServices: .init(
                makePayments: { payload in Payments() }
            )
        )
        
        return .init(
            microServices: .init(
                bind: factory.bind(with: witnesses),
                getNavigation: getNavigationComposer.getNavigation,
                makeQR: QRModel.init
            ),
            mainScheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
    }
}
