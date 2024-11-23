//
//  RootViewModel+rootEventPublisherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.11.2024.
//

@testable import ForaBank
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
    
    func test_init_shouldEmitScanQROnMainViewSectionsEmitScanQR() throws {
        
        let (sut, spy) = makeSUT()
        let sections = mainViewSections(sut)
        
        for index in sections.indices {
            
            emit(.scanQR, from: sections[index])
            
            let value = spy.values[index]
            XCTAssertNoDiff(value, .scanQR, "Expected `scanQR` RootEvent from \(sections[index]) at \(index), but got \(value) instead.")
        }
        
        XCTAssertEqual(sections.count, 6)
        XCTAssertNoDiff(spy.values, .init(repeating: .scanQR, count: 6), "Expected \(6) `scanQR` RootEvents, but got \(spy.values.count) instead.")
    }
    
    func test_init_shouldEmitScanQROnMainViewFastOperationSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapMainViewFastSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [.scanQR])
    }
    
    func test_init_shouldEmitScanQROnLegacyPaymentsTransfersPaymentsSectionQRButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapLegacyPaymentsSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [.scanQR])
    }
    
    // MARK: - templates
    
    func test_init_shouldEmitTemplatesOnMainViewFastOperationSectionTemplatesButtonAction() throws {
        
        let (sut, spy) = makeSUT()
        
        try tapMainViewFastSectionTemplatesButton(sut)
        
        XCTAssertNoDiff(spy.values, [.templates])
    }
}
