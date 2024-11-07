//
//  QRBinderComposerIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import CombineSchedulers
import PayHub
import PayHubUI
import XCTest

final class QRBinderComposerIntegrationTests: QRBinderTests {
    
    func test_init() {
        
        let sut = makeSUT()
        
        _ = sut.compose()
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRBinderComposer<Navigation, QR, QRResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let mainScheduler: AnySchedulerOf<DispatchQueue> = .immediate
        let interactiveScheduler: AnySchedulerOf<DispatchQueue> = .immediate
        
        let factory = ContentFlowBindingFactory(scheduler: mainScheduler)
        let witnesses = Witnesses(
            contentEmitting: { $0.publisher },
            contentReceiving: { content in { content.receive() }},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
        let makeQRFailure = MakeQRFailure()
        let makePayments = MakePayments()
        let makeMixedPicker = MakeMixedPicker()
        let getNavigationComposer = NavigationComposer(
            microServices: .init(
                makeQRFailure: makeQRFailure.call,
                makePayments: makePayments.call,
                makeMixedPicker: makeMixedPicker.call
            ),
            witnesses: .init(
                mixedPicker: .init(
                    isClosed: { $0.isClosed },
                    scanQR: { $0.scanQRPublisher }
                ),
                payments: .init(
                    isClosed: { $0.isClosed },
                    scanQR: { $0.scanQRPublisher }
                ),
                qrFailure: .init(
                    isClosed: { _ in fatalError() },
                    scanQR: { $0.scanQRPublisher }
                )
            )
        )
        let sut = QRBinderComposer(
            microServices: .init(
                bind: factory.bind(with: witnesses),
                getNavigation: getNavigationComposer.getNavigation,
                makeQR: makeQR
            ),
            mainScheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(factory, file: file, line: line)
        trackForMemoryLeaks(makePayments, file: file, line: line)
        trackForMemoryLeaks(getNavigationComposer, file: file, line: line)
        // trackForMemoryLeaks(mainScheduler, file: file, line: line)
        // trackForMemoryLeaks(interactiveScheduler, file: file, line: line)
        
        return sut
    }
}
