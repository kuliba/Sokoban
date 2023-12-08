//
//  SberQRConfirmPaymentViewModelTests.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import CombineSchedulers
import SberQR
import XCTest

final class SberQRConfirmPaymentViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialState_fixed() {
        
        let initialState: SUT.State = .fixedAmount(makeFixedAmount(
            productSelect: .compact(.test2)
        ))
        let (_, spy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_init_shouldSetInitialState_editable() {
        
        let initialState: SUT.State = .editableAmount(makeEditableAmount(
            productSelect: .compact(.test2)
        ))
        let (_, spy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRConfirmPaymentViewModel
    private typealias Spy = ValueSpy<SUT.State>
    
    private func makeSUT(
        initialState: SUT.State = .fixedAmount(makeFixedAmount()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let sut = SUT(
            initialState: initialState,
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
