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
        
        let (_, ppoEffectHandler, ppEffectHandler) = makeSUT()
        
        XCTAssertEqual(ppoEffectHandler.callCount, 0)
        XCTAssertEqual(ppEffectHandler.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_prePaymentOptionsEffect_initiate_shouldCallPrePaymentOptionsHandleEffectWithEffect() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .initiate
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldDeliverPrePaymentOptionsHandleEffectEvent_didScrollTo() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        let effect: SUT.PPOEffect = .initiate
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldDeliverPrePaymentOptionsHandleEffectEvent_initiate() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        let effect: SUT.PPOEffect = .initiate
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldDeliverPrePaymentOptionsHandleEffectEvent_loaded() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        let effect: SUT.PPOEffect = .initiate
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldDeliverPrePaymentOptionsHandleEffectEvent_paginated() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        let effect: SUT.PPOEffect = .initiate
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_initiate_shouldDeliverPrePaymentOptionsHandleEffectEvent_search() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        let effect: SUT.PPOEffect = .initiate
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    // MARK: - paginate
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_didScrollTo() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldDeliverPrePaymentOptionsHandleEffectEvent_didScrollTo() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_initiate() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldDeliverPrePaymentOptionsHandleEffectEvent_initiate() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_loaded() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldDeliverPrePaymentOptionsHandleEffectEvent_loaded() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_paginated() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldDeliverPrePaymentOptionsHandleEffectEvent_paginated() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldCallPrePaymentOptionsHandleEffect_search() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_paginate_shouldDeliverPrePaymentOptionsHandleEffectEvent_search() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        let effect: SUT.PPOEffect = .paginate("abc", 13)
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    // MARK: - search
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_didScrollTo() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .search("abc")
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_search_shouldDeliverPrePaymentOptionsHandleEffectEvent_didScrollTo() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .didScrollTo("123")
        let effect: SUT.PPOEffect = .search("abc")
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_initiate() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .search("abc")
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_search_shouldDeliverPrePaymentOptionsHandleEffectEvent_initiate() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .initiate
        let effect: SUT.PPOEffect = .search("abc")
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_loaded() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .search("abc")
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_search_shouldDeliverPrePaymentOptionsHandleEffectEvent_loaded() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .loaded(
            .failure(.connectivityError), .failure(.serverError(anyMessage()))
        )
        let effect: SUT.PPOEffect = .search("abc")
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_paginated() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .search("abc")
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_search_shouldDeliverPrePaymentOptionsHandleEffectEvent_paginated() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .paginated(.success([makeOperator()]))
        let effect: SUT.PPOEffect = .search("abc")
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    func test_prePaymentOptionsEffect_search_shouldCallPrePaymentOptionsHandleEffect_search() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let effect: SUT.PPOEffect = .search("abc")
        
        sut.handleEffect(.prePaymentOptions(effect)) { _ in }
        
        XCTAssertNoDiff(ppoEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentOptionsEffect_search_shouldDeliverPrePaymentOptionsHandleEffectEvent_search() {
        
        let (sut, ppoEffectHandler, _) = makeSUT()
        let event: SUT.PPOEvent = .search(.entered("abc"))
        let effect: SUT.PPOEffect = .search("abc")
        
        expect(sut, with: .prePaymentOptions(effect), toDeliver: .prePaymentOptions(event), on: {
            
            ppoEffectHandler.complete(with: event)
        })
    }
    
    // MARK: - select
    
    func test_prePaymentEffect_startPayment_shouldCallPrePaymentHandleEffect_startPayment() {
        
        let (sut, _, ppEffectHandler) = makeSUT()
        let effect: SUT.PPEffect = .select(.last(makeLastPayment()))
        
        sut.handleEffect(.prePayment(effect)) { _ in }
        
        XCTAssertNoDiff(ppEffectHandler.messages.map(\.effect), [effect])
    }
    
    func test_prePaymentEffect_startPayment_shouldDeliverPrePaymentOptionsHandleEffectEvent_startPayment() {
        
        let (sut, _, ppEffectHandler) = makeSUT()
        let event: SUT.PPEvent = .paymentStarted(.failure(.connectivityError))
        let effect: SUT.PPEffect = .select(.operator(makeOperator()))
        
        expect(sut, with: .prePayment(effect), toDeliver: .prePayment(event), on: {
            
            ppEffectHandler.complete(with: event)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowEffectHandler<LastPayment, Operator, StartPaymentResponse, Service>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias PPOEffectHandlerSpy = EffectHandlerSpy<SUT.PPOEvent, SUT.PPOEffect>
    private typealias PPEffectHandlerSpy = EffectHandlerSpy<SUT.PPEvent, SUT.PPEffect>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoEffectHandler: PPOEffectHandlerSpy,
        ppEffectHandler: PPEffectHandlerSpy
    ) {
        let ppoEffectHandler = PPOEffectHandlerSpy()
        let ppEffectHandler = PPEffectHandlerSpy()
        let sut = SUT(
            ppoHandleEffect: ppoEffectHandler.handleEffect(_:_:),
            ppHandleEffect: ppEffectHandler.handleEffect(_:_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoEffectHandler, file: file, line: line)
        trackForMemoryLeaks(ppEffectHandler, file: file, line: line)
        
        return (sut, ppoEffectHandler, ppEffectHandler)
    }
    
    private func makeLastPayment(
        value: String = UUID().uuidString
    ) -> LastPayment {
        
        .init(value: value)
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
    }
}
