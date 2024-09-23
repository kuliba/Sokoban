//
//  FailedPaymentProviderPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

struct FailedPaymentProviderPickerFlowState: Equatable {}
enum FailedPaymentProviderPickerFlowEvent: Equatable {}
enum FailedPaymentProviderPickerFlowEffect: Equatable {}

final class FailedPaymentProviderPickerFlowReducer {
    
    init() {}
}

extension FailedPaymentProviderPickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        }
        
        return (state, effect)
    }
}

extension FailedPaymentProviderPickerFlowReducer {
    
    typealias State = FailedPaymentProviderPickerFlowState
    typealias Event = FailedPaymentProviderPickerFlowEvent
    typealias Effect = FailedPaymentProviderPickerFlowEffect
}

import PayHub
import XCTest

final class FailedPaymentProviderPickerFlowReducerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerFlowReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
