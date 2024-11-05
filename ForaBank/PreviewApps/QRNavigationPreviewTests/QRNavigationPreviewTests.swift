//
//  QRNavigationPreviewTests.swift
//  QRNavigationPreviewTests
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
                    completion(.qr(.init(model: qr, cancellables: [])))
                }
            },
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose()
    }
}

private extension ContentViewModelComposer {
    
#warning("remove QRNavigationPreview prefix after move to prod")
    typealias QRDomain = QRNavigationPreview.QRDomain
    typealias QRNavigation = QRNavigationPreview.QRNavigation
    typealias QRResult = QRNavigationPreview.QRResult
    
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

@testable import QRNavigationPreview
import XCTest

final class QRNavigationPreviewTests: XCTestCase {
    
    func test_shouldSetNavigationOnSelect() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        
        XCTAssertNoDiff(equatable(flow.state), .init(navigation: .qr))
    }
    
    func test_shouldResetNavigationOnDismiss() {
        
        let flow = makeSUT().compose()
        
        flow.event(.select(.scanQR))
        XCTAssertNoDiff(equatable(flow.state), .init(navigation: .qr))
        
        flow.event(.dismiss)
        
        XCTAssertNil(flow.state.navigation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentViewModelComposer
    private typealias State = ContentViewDomain.State
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            mainScheduler: .immediate,
            interactiveScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func equatable(_ state: State) -> EquatableState {
        
        switch state.navigation {
        case .none:
            return .init(isLoading: state.isLoading, navigation: .none)
            
        case .qr:
            return .init(isLoading: state.isLoading, navigation: .qr)
        }
    }
    
    private struct EquatableState: Equatable {
        
        var isLoading = false
        let navigation: EquatableNavigation?
        
        enum EquatableNavigation: Equatable {
            
            case qr
        }
    }
}
