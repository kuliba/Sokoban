//
//  PayHubEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubEvent {}
enum PayHubEffect {}

struct PayHubEffectHandlerMicroServices {
    
}

final class PayHubEffectHandler {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices
}

extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent
    typealias Effect = PayHubEffect
}


import XCTest

final class PayHubEffectHandlerTests: XCTestCase {
        
    // MARK: - Helpers
    
    private typealias SUT = PayHubEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            microServices: .init()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
}
