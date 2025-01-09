//
//  QRBinderComposerIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import CombineSchedulers
import FlowCore
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
        
        let factory = ContentFlowBindingFactory()
        let witnesses = Witnesses(
            contentEmitting: { $0.publisher },
            contentDismissing: { content in { content.dismiss() }},
            flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
            flowReceiving: { flow in { flow.event(.select($0)) }}
        )
        
        let makeConfirmSberQR = MakeConfirmSberQR()
        let makeMixedPicker = MakeMixedPicker()
        let makeMultiplePicker = MakeMultiplePicker()
        let makeOperatorModel = MakeOperatorModel()
        let makePayments = MakePayments()
        let makeQRFailure = MakeQRFailure()
        let makeServicePicker = MakeServicePicker()
        
        let getNavigationComposer = NavigationComposer(
            firstMicroServices: .init(
                makePayments: makePayments.call,
                makeQRFailure: makeQRFailure.call
            ),
            secondMicroServices: .init(
                makeConfirmSberQR: makeConfirmSberQR.process,
                makeMixedPicker: makeMixedPicker.call,
                makeMultiplePicker: makeMultiplePicker.call,
                makeOperatorModel: makeOperatorModel.call,
                makeServicePicker: makeServicePicker.call
            ),
            witnesses: .init(
                addCompany: .init(
                    mixedPicker: { $0.publisher(for: \.addCompany) },
                    multiplePicker: { $0.publisher(for: \.addCompany) },
                    servicePicker: { $0.publisher(for: \.goToChat) }
                ),
                goToMain: .init(
                    servicePicker: { $0.publisher(for: \.goToChat) }
                ),
                goToPayments: .init(
                    servicePicker: { $0.publisher(for: \.goToPayments) }
                ),
                isClosed: .init(
                    mixedPicker: { $0.publisher(for: \.isClosed) },
                    multiplePicker: { $0.publisher(for: \.isClosed) },
                    payments: { $0.publisher(for: \.isClosed) },
                    qrFailure: { $0.publisher(for: \.isClosed) },
                    servicePicker: { _ in Empty().eraseToAnyPublisher() }
                ),
                scanQR: .init(
                    mixedPicker: { $0.publisher(for: \.scanQR) },
                    multiplePicker: { $0.publisher(for: \.scanQR) },
                    payments: { $0.publisher(for: \.scanQR) },
                    qrFailure: { $0.publisher(for: \.scanQR) },
                    servicePicker: { $0.publisher(for: \.scanQR) }
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
