//
//  TransfersButtonVMFactoryTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.10.2024.
//

struct TransfersButtonVMFactory {
    
}

@testable import ForaBank
import XCTest

final class TransfersButtonVMFactoryTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransfersButtonVMFactory
    private typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    private typealias ActionSpy = CallSpy<ButtonType, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ActionSpy
    ) {
        let spy = ActionSpy()
        let sut = SUT()
        
        return (sut, spy)
    }
}
