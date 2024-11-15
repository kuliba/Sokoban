//
//  RootViewModel+rootEventPublisherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.11.2024.
//

@testable import ForaBank
import PayHubUI
import XCTest

final class RootViewModel_rootEventPublisherTests: XCTestCase {
    
    func test_init_shouldNotEmit() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertNotNil(sut)
    }
    
    func test_init_shouldEmitScanQROnMainViewSectionsEmitScanQR() throws {
        
        let (sut, spy) = makeSUT()
        let sections = sut.mainViewSections
        
        for index in sections.indices {
            
            sections[index].emit(.scanQR)
            
            let value = spy.values[index]
            XCTAssertNoDiff(value, .scanQR, "Expected `scanQR` RootEvent from \(sections[index]) at \(index), but got \(value) instead.")
        }
        
        XCTAssertEqual(sections.count, 6)
        XCTAssertNoDiff(spy.values, .init(repeating: .scanQR, count: 6), "Expected \(6) `scanQR` RootEvents, but got \(spy.values.count) instead.")
    }
    
    func test_init_shouldEmitScanQROnMainViewFastOperationSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try sut.tapMainViewFastSectionQRButton()
        
        XCTAssertNoDiff(spy.values, [.scanQR])
    }
    
    func test_init_shouldEmitScanQROnLegacyPaymentsTransfersPaymentsSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try sut.tapLegacyPaymentsSectionQRButton()
        
        XCTAssertNoDiff(spy.values, [.scanQR])
    }
    
    // MARK: - Helpers
    
    private typealias Domain = ForaBank.RootViewDomain
    private typealias Witnesses = ContentWitnesses<RootViewModel, Domain.Select>
    private typealias SUT = RootViewModel
    private typealias Emitting = Witnesses.Emitting
    private typealias Spy = ValueSpy<Domain.Select>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RootViewModel,
        spy: Spy
    ) {
        let model: Model = .mockWithEmptyExcept()
        
        let sut = RootViewModel(
            fastPaymentsFactory: .legacy,
            stickerViewFactory: .preview,
            navigationStateManager: .preview,
            productNavigationStateManager: .preview,
            tabsViewModel: .init(
                mainViewModel: .init(
                    model,
                    makeProductProfileViewModel: { _,_,_,_  in nil },
                    navigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    landingServices: .empty(),
                    paymentsTransfersFactory: .preview,
                    updateInfoStatusFlag: .inactive,
                    onRegister: {},
                    bannersBinder: .preview
                ),
                paymentsModel: .legacy(.init(
                    model: model,
                    makeFlowManager: { _ in .preview },
                    userAccountNavigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    paymentsTransfersFactory: .preview
                )),
                chatViewModel: .init(),
                marketShowcaseBinder: .preview
            ),
            informerViewModel: .init(model),
            model,
            showLoginAction: { _ in
                
                    .init(viewModel: .init(authLoginViewModel: .preview))
            },
            landingServices: .empty(),
            mainScheduler: .immediate
        )
        
        let spy = Spy(sut.rootEventPublisher)
        
        // FIXME: fie Model memory leaks
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
}

// MARK: - DSL

private extension RootViewModel {
    
    var mainViewModel: MainViewModel {
        
        return tabsViewModel.mainViewModel
    }
    
    var mainViewSections: [MainSectionViewModel] {
        
        return mainViewModel.sections
    }
    
    func tapMainViewFastSectionQRButton() throws {
        
        try mainViewModel.tapFastSectionQRButton()
    }
    
    func legacyPaymentsTransfers() throws -> PaymentsTransfersViewModel {
        
        switch tabsViewModel.paymentsModel {
        case let .legacy(paymentsTransfers):
            return paymentsTransfers
            
        default:
            throw NSError(domain: "Expected Legacy PaymentsTransfers", code: -1)
        }
    }
    
    func tapLegacyPaymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try legacyPaymentsTransfers().tapPaymentsSectionQRButton(file: file, line: line)
    }
}

private extension MainSectionViewModel {
    
    func emit(_ event: RootEvent) {
        
        action.send(event)
    }
}

private extension MainViewModel {
    
    typealias FastSection = MainSectionFastOperationView.ViewModel
    
    func fastSection(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> FastSection {
        
        let sections = sections.compactMap { $0 as? FastSection }
        
        return try XCTUnwrap(sections.first, "Expected to have Fast Section", file: file, line: line)
    }
    
    func fastSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ButtonIconTextView.ViewModel {
        
        let buttons = try fastSection(file: file, line: line).items
        
        return try XCTUnwrap(buttons.first, "Expected to have QR Button as first", file: file, line: line)
    }
    
    func tapFastSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try fastSectionQRButton(file: file, line: line).action()
    }
}

private extension PaymentsTransfersViewModel {
    
    typealias PaymentsSection = PTSectionPaymentsView.ViewModel
    
    func paymentsSection(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsSection {
        
        let sections = sections.compactMap { $0 as? PaymentsSection }
            
        return try XCTUnwrap(sections.first, "Expected to have Payments Section", file: file, line: line)
    }
    
    func paymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsSection.PaymentButtonVM {
        
        let buttons = try paymentsSection(file: file, line: line).paymentButtons
            .filter { $0.type == .qrPayment }
        
        return try XCTUnwrap(buttons.first, "Expected to have QR Button in Payments Section", file: file, line: line)
    }
    
    func tapPaymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try paymentsSectionQRButton(file: file, line: line).action()
    }
}
