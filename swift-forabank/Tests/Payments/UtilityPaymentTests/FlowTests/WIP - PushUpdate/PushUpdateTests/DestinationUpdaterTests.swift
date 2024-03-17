//
//  DestinationUpdaterTests.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

enum UpdateFlowEvent {
    
    case initiate
}

extension UpdateFlowEvent: Equatable {}

enum UpdateFlowEffect {
    
    case initiate
}

extension UpdateFlowEffect: Equatable {}

final class DestinationUpdater {
    
}

extension DestinationUpdater {
    
    func update(
        _ state: State,
        _ event: Event
    ) -> (Destination?, Effect?) {
        
        switch event {
        case .initiate:
            return (nil, .initiate)
        }
    }
}

extension DestinationUpdater {
    
    typealias Destination = UtilityDestination<LastPayment, Operator, Service>
    
    typealias State = Flow<UtilityDestination<LastPayment, Operator, Service>>
    typealias Event = UpdateFlowEvent
    typealias Effect = UpdateFlowEffect
}

final class StackStacker {
    
}

extension StackStacker {
    
    func push(
        _ state: State,
        _ event: Event
    ) -> (Destination, Effect?) {
        
        fatalError()
    }
}

extension StackStacker {
    
    typealias Destination = UtilityDestination<LastPayment, Operator, Service>
    
    typealias State = Flow<UtilityDestination<LastPayment, Operator, Service>>
    typealias Event = PushEvent
    typealias Effect = PushEffect
}

final class DestinationUpdaterTests: XCTestCase {
    
    func test_initiate_shouldDeliverNilDestinationOnEmptyState() {
        
        let emptyState = State()
        let sut = makeSUT()
        
        let (destination, _) = sut.update(emptyState, .initiate)
        
        XCTAssertNil(destination)
    }
    
    func test_initiate_shouldDeliverEffectOnEmptyState() {
        
        let emptyState = State()
        let sut = makeSUT()
        
        let (_, effect) = sut.update(emptyState, .initiate)
        
        XCTAssertNoDiff(effect, .initiate)
    }
    
    func test_initiate_shouldDeliverNilDestinationOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services(makeServices())))
        let sut = makeSUT()
        
        let (destination, _) = sut.update(nonEmptyState, .initiate)
        
        XCTAssertNil(destination)
    }
    
    func test_initiate_shouldDeliverEffectOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services(makeServices())))
        let sut = makeSUT()
        
        let (_, effect) = sut.update(nonEmptyState, .initiate)
        
        XCTAssertNoDiff(effect, .initiate)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DestinationUpdater
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
