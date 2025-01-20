//
//  RootViewModel+rootEventPublisherTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.11.2024.
//

import Combine
@testable import Vortex
import PayHubUI
import XCTest

final class RootViewModel_rootEventPublisherTests: RootViewModel_Tests {
    
    // MARK: - init
    
    func test_init_shouldNotEmit() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.values, [])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - scan QR
    
    func test_shouldEmitScanQROnMainViewSectionsEmitScanQR() throws {
        
        let (sut, spy) = makeSUT()
        let sections = mainViewSections(sut)
        
        for index in sections.indices {
            
            emit(.select(.scanQR), from: sections[index])
            
            let value = spy.values[index]
            XCTAssertNoDiff(value, .select(.scanQR), "Expected `scanQR` RootEvent from \(sections[index]) at \(index), but got \(value) instead.")
        }
        
        XCTAssertEqual(sections.count, 6)
        XCTAssertNoDiff(spy.values, .init(repeating: .select(.scanQR), count: 6), "Expected \(6) `scanQR` RootEvents, but got \(spy.values.count) instead.")
    }
    
    func test_shouldEmitScanQROnMainViewFastOperationSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapMainViewFastSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [.select(.scanQR)])
    }
    
    func test_shouldEmitScanQROnLegacyPaymentsTransfersPaymentsSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapLegacyPaymentsSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [.select(.scanQR)])
    }
    
    // MARK: - templates
    
    func test_shouldEmitTemplatesOnMainViewFastOperationSectionTemplatesButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapMainViewFastSectionTemplatesButton(sut)
        
        XCTAssertNoDiff(spy.values, [.select(.templates)])
    }
    
    func test_shouldEmitTemplatesOnOperationPickerSelectTemplates() throws {
        
        let (sut, spy) = makeSUTWithV1(hasCorporateCardsOnly: false)
        
        try sut.operationPickerContentSelect(.templates)
        
        XCTAssertNoDiff(spy.values, [.select(.templates)])
    }
    
    // MARK: - userAccount
    
    func test_shouldEmitUserAccountOnPaymentsTransfersCorporateUserAccountSelect() throws {
        
        let (sut, spy) = makeSUTWithV1(hasCorporateCardsOnly: true)
        
        sut.paymentsTransfersCorporateSelect(.userAccount)
        
        XCTAssertNoDiff(spy.values, [.select(.userAccount)])
    }
    
    func test_shouldEmitUserAccountOnPaymentsTransfersPersonalUserAccountSelect() throws {
        
        let (sut, spy) = makeSUTWithV1(hasCorporateCardsOnly: false)
        
        sut.paymentsTransfersPersonalSelect(.userAccount)
        
        XCTAssertNoDiff(spy.values, [.select(.userAccount)])
    }
    
    // MARK: - Helpers
    
    private func makeSUTWithV1(
        hasCorporateCardsOnly: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RootViewModel,
        spy: Spy
    ) {
        let hasCorporateCardsOnlySubject = PassthroughSubject<Bool, Never>()
        let (sut, spy) = makeSUT(paymentsModel: .v1(makeSwitcher(
            hasCorporateCardsOnlySubject: hasCorporateCardsOnlySubject
        )))
        hasCorporateCardsOnlySubject.send(hasCorporateCardsOnly)
        
        return (sut, spy)
    }
    
    private func makeSwitcher(
        hasCorporateCardsOnlySubject: PassthroughSubject<Bool, Never>
    ) -> PaymentsTransfersSwitcher {
        
        let factory = RootViewModelFactory(
            model: .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            mapScanResult: { _,_ in unimplemented() },
            resolveQR: { _ in unimplemented() },
            scanner: QRScannerViewModelSpy(),
            schedulers: .immediate
        )
        let switcher = PaymentsTransfersSwitcher(
            hasCorporateCardsOnly: hasCorporateCardsOnlySubject.eraseToAnyPublisher(),
            corporate: factory.makePaymentsTransfersCorporate(
                bannerPickerPlaceholderCount: 6,
                nanoServices: .init(
                    loadBanners: { _ in unimplemented() }
                )
            ),
            personal: factory.makePaymentsTransfersPersonal().0,
            scheduler: .immediate
        )
        
        return switcher
    }
}

private extension RootViewModel {
    
    func switcher(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsTransfersSwitcher? {
        
        switch tabsViewModel.paymentsModel {
        case let .v1(switcher):
            let switcher = switcher as? PaymentsTransfersSwitcher
            
            switch switcher {
            case let .some(switcher):
                return switcher
                
            default:
                XCTFail("Expected PaymentsTransfersSwitcher, but got \(String(describing: switcher)) instead.", file: file, line: line)
                return nil
            }
            
        default:
            XCTFail("Expected v1, but got \(tabsViewModel.paymentsModel) instead.", file: file, line: line)
            return nil
        }
    }
    
    func paymentsTransfersCorporateSelect(
        _ select: Vortex.PaymentsTransfersCorporateDomain.Select,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let switcher = switcher(file: file, line: line)
        switch switcher?.state {
        case let .corporate(corporate):
            corporate.flow.event(.select(select))
            
        default:
            XCTFail("Expected Corporate, but got \(String(describing: switcher?.state)) instead.", file: file, line: line)
        }
    }
    
    func paymentsTransfersPersonalSelect(
        _ select: Vortex.PaymentsTransfersPersonalDomain.Select,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let switcher = switcher(file: file, line: line)
        switch switcher?.state {
        case let .personal(personal):
            personal.flow.event(.select(select))
            
        default:
            XCTFail("Expected Personal, but got \(String(describing: switcher?.state)) instead.", file: file, line: line)
        }
    }
    
    func operationPicker(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Vortex.OperationPickerDomain.Binder? {
        
        let switcher = switcher(file: file, line: line)
        switch switcher?.state {
        case let .personal(personal):
            switch personal.content.operationPicker.operationBinder {
            case .none:
                XCTFail("Expected OperationPicker, but got nil instead.", file: file, line: line)
                return nil
                
            case let .some(binder):
                return binder
            }
            
        default:
            XCTFail("Expected OperationPicker, but got \(String(describing: switcher?.state)) instead.", file: file, line: line)
            return nil
        }
    }
    
    func operationPickerContentSelect(
        _ select: Vortex.OperationPickerDomain.Select,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let operationPicker = try XCTUnwrap(operationPicker(file: file, line: line))
        operationPicker.content.event(.select(select))
    }
}
