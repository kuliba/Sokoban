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
    
    private typealias SUT = QRBinderComposer<Navigation, QR, Select>
    
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
        let makeMixedPicker = MakeMixedPicker()
        let makeMultiplePicker = MakeMultiplePicker()
        let makePayments = MakePayments()
        let makeQRFailure = MakeQRFailure()
        let makeServicePicker = MakeServicePicker()
        let getNavigationComposer = NavigationComposer(
            microServices: .init(
                makeMixedPicker: makeMixedPicker.call,
                makeMultiplePicker: makeMultiplePicker.call,
                makePayments: makePayments.call,
                makeQRFailure: makeQRFailure.call,
                makeServicePicker: makeServicePicker.call
            ),
            witnesses: .init(
                addCompany: .init(
                    mixedPicker: { $0.addCompanyPublisher },
                    multiplePicker: { $0.addCompanyPublisher },
                    servicePicker: { $0.addCompanyPublisher }
                ),
                goToMain: .init(
                    servicePicker: { $0.goToMainPublisher }
                ),
                goToPayments: .init(
                    servicePicker: { $0.goToPaymentsPublisher }
                ),
                isClosed: .init(
                    mixedPicker: { $0.isClosed },
                    multiplePicker: { $0.isClosed },
                    payments: { $0.isClosed },
                    qrFailure: { $0.isClosed }
                ),
                scanQR: .init(
                    mixedPicker: { $0.scanQRPublisher },
                    multiplePicker: { $0.scanQRPublisher },
                    payments: { $0.scanQRPublisher },
                    qrFailure: { $0.scanQRPublisher }
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
