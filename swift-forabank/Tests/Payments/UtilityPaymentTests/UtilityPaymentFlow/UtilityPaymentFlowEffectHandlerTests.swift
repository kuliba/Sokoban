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
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffect_didScrollTo() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        
        expect(sut, with: .prePaymentOptions(.initiate), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffect_initiate() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        
        expect(sut, with: .prePaymentOptions(.initiate), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffect_loaded() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        
        expect(sut, with: .prePaymentOptions(.initiate), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffect_paginated() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        
        expect(sut, with: .prePaymentOptions(.initiate), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffect_search() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        
        expect(sut, with: .prePaymentOptions(.initiate), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_didScrollTo() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        
        expect(sut, with: .prePaymentOptions(.paginate("", 1)), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_initiate() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        
        expect(sut, with: .prePaymentOptions(.paginate("", 1)), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_loaded() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        
        expect(sut, with: .prePaymentOptions(.paginate("", 1)), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_paginated() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        
        expect(sut, with: .prePaymentOptions(.paginate("", 1)), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_search() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        
        expect(sut, with: .prePaymentOptions(.paginate("", 1)), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_didScrollTo() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        
        expect(sut, with: .prePaymentOptions(.search("abc")), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_initiate() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        
        expect(sut, with: .prePaymentOptions(.search("abc")), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_loaded() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        
        expect(sut, with: .prePaymentOptions(.search("abc")), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_paginated() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        
        expect(sut, with: .prePaymentOptions(.search("abc")), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_search() {
        
        let (sut, ppoEffectHandler) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        
        expect(sut, with: .prePaymentOptions(.search("abc")), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowEffectHandler<LastPayment, Operator>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
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
    
    private func makeOperator(
        value: String = UUID().uuidString
    ) -> Operator {
        
        .init(value: value)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}
