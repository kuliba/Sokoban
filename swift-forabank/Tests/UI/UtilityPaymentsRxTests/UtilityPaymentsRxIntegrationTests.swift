//
//  UtilityPaymentsRxIntegrationTests.swift
//  
//
//  Created by Igor Malyarov on 19.02.2024.
//

import RxViewModel
import UtilityPaymentsRx
import XCTest

private typealias UtilityPaymentsViewModel = RxViewModel<UtilityPaymentsState, UtilityPaymentsEvent, UtilityPaymentsEffect>

final class UtilityPaymentsRxIntegrationTests: XCTestCase {
    
    func test_init___() {
        
        _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentsViewModel
    private typealias State = UtilityPaymentsState
    private typealias Event = UtilityPaymentsEvent
    private typealias Effect = UtilityPaymentsEffect

    private func makeSUT(
        initialState: UtilityPaymentsState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let reducer = UtilityPaymentsReducer()
        let effectHandler = UtilityPaymentsEffectHandler()
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
