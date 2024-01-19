//
//  OTPInputReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent
import XCTest

final class OTPInputReducerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = OTPInputReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
