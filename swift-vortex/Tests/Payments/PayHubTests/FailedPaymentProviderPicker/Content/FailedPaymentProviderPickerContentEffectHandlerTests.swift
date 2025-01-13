//
//  FailedPaymentProviderPickerContentEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

import PayHub
import XCTest

final class FailedPaymentProviderPickerContentEffectHandlerTests: XCTestCase {

    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerContentEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(microServices: .init())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

}
