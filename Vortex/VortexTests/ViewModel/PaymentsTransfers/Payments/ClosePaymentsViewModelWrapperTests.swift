//
//  ClosePaymentsViewModelWrapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.09.2024.
//

@testable import ForaBank
import XCTest

final class ClosePaymentsViewModelWrapperTests: XCTestCase {
    
    func test_init_shouldSetStateToFalse() {
        
        let (sut, stateSpy) = makeSUT()
        
        XCTAssertNoDiff(stateSpy.values, [false])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetStateToTrueOnCloseAction() {
        
        let (sut, stateSpy) = makeSUT()
        
        sut.paymentsViewModel.closeAction()
        
        XCTAssertNoDiff(stateSpy.values, [false, true])
    }
    
    func test_shouldNotChangeStateTwice() {
        
        let (sut, stateSpy) = makeSUT()
        
        sut.paymentsViewModel.closeAction()
        sut.paymentsViewModel.closeAction()
        
        XCTAssertNoDiff(stateSpy.values, [false, true])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ClosePaymentsViewModelWrapper
    private typealias StateSpy = ValueSpy<Bool>
    
    private func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        service: Payments.Service = .mobileConnection,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy
    ) {
        let sut = SUT(
            model: model, 
            service: service,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$isClosed)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, stateSpy)
    }
}
