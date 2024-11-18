//
//  RootViewDomainContentWitnessesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewDomain.ContentWitnesses {
    
    init(isFlagActive: Bool) {
        
        self.init(
            emitting: {
            
                if isFlagActive {
                    $0.rootEventPublisher
                } else {
                    Empty().eraseToAnyPublisher()
                }
            },
            receiving: { _ in {}}
        )
    }
}

@testable import ForaBank
import XCTest

final class RootViewDomainContentWitnessesTests: RootViewModel_Tests {
    
    // MARK: - emitting
    
    func test_emitting_shouldNotEmitOnMainViewFastOperationSectionQRButtonAction_flagInactive() throws {
        
        let (sut, spy) = makeSUT(isFlagActive: false)
        
        try tapMainViewFastSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_emitting_shouldEmitOnMainViewFastOperationSectionQRButtonAction_flagActive() throws {
        
        let (sut, spy) = makeSUT(isFlagActive: true)
        
        try tapMainViewFastSectionQRButton(sut)
        
        XCTAssertNoDiff(spy.values, [.scanQR])
    }
    
    // MARK: - Helpers
    
    private typealias Witnesses = RootViewDomain.ContentWitnesses
    private typealias RootEventSpy = ValueSpy<RootEvent>
    
    private func makeSUT(
        isFlagActive: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (SUT, RootEventSpy) {
        
        let sut = makeSUT(file: file, line: line).sut
        let witness = Witnesses(isFlagActive: isFlagActive)
        let spy = RootEventSpy(witness.emitting(sut))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
