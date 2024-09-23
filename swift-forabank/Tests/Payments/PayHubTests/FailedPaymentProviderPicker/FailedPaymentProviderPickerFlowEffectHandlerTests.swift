//
//  FailedPaymentProviderPickerFlowEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

struct FailedPaymentProviderPickerFlowEffectHandlerMicroServices {}

extension FailedPaymentProviderPickerFlowEffectHandlerMicroServices {}

final class FailedPaymentProviderPickerFlowEffectHandler {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = FailedPaymentProviderPickerFlowEffectHandlerMicroServices
}

extension FailedPaymentProviderPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension FailedPaymentProviderPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FailedPaymentProviderPickerFlowEvent
    typealias Effect = FailedPaymentProviderPickerFlowEffect
}


import PayHub
import XCTest

final class FailedPaymentProviderPickerFlowEffectHandlerTests: XCTestCase {

    // MARK: - Helpers
    
    private typealias SUT = FailedPaymentProviderPickerFlowEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(microServices: .init())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

}
