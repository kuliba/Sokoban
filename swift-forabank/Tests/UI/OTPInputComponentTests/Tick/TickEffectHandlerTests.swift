//
//  TickEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class TickEffectHandler {
    
}

extension TickEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

extension TickEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}

import XCTest

final class TickEffectHandlerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = TickEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
