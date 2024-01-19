//
//  OTPInputEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

final class OTPInputEffectHandler {
    
}

extension OTPInputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

extension OTPInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

import XCTest

final class OTPInputEffectHandlerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
