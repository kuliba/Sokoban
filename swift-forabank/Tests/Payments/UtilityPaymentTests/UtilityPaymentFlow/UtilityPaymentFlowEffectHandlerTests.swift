//
//  UtilityPaymentFlowEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 09.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class UtilityPaymentFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let _ = makeSUT()
        
        // TODO: add assertion
    }
    
    func test_prePaymentOptionsEffectShouldCallPrePaymentOptionsHandleEffect() {
        
        
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowEffectHandler<LastPayment, Operator>
    
    private typealias PPOEffectHandler = PrePaymentOptionsEffectHandler<LastPayment, Operator>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

