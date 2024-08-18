//
//  QRFlowEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

enum QRFlowEvent: Equatable {}

enum QRFlowEffect: Equatable {}

struct QRFlowEffectHandlerMicroServices {}

extension QRFlowEffectHandlerMicroServices {}

final class QRFlowEffectHandler {

    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = QRFlowEffectHandlerMicroServices
}

extension QRFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension QRFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = QRFlowEvent
    typealias Effect = QRFlowEffect
}


import XCTest

final class QRFlowEffectHandlerTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowEffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(microServices: .init(
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            receivedEvents.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedEvents, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
