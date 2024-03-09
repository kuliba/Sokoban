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
        
        let (_, ppoEffectHandler) = makeSUT()
        
        XCTAssertEqual(ppoEffectHandler.callCount, 0)
    }
    
    func test_prePaymentOptionsEffectShouldCallPrePaymentOptionsHandleEffect() {
        
        
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowEffectHandler<LastPayment, Operator>
    
    private typealias PPOEffectHandlerSpy = EffectHandlerSpy<SUT.PPOEvent, SUT.PPOEffect>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoEffectHandler: PPOEffectHandlerSpy
    ) {
        let ppoEffectHandler = PPOEffectHandlerSpy()
        let sut = SUT(
            ppoHandleEffect: ppoEffectHandler.handleEffect(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoEffectHandler, file: file, line: line)
        
        return (sut, ppoEffectHandler)
    }
}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}
