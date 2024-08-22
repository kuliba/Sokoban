//
//  OperationPickerFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import PayHub
import XCTest

final class OperationPickerFlowEffectHandlerTests: OperationPickerFlowTests {
    
    // MARK: - select
    
    func test_select_shouldDeliverNilOnNil() throws {
        
        let sut = makeSUT()
        
        expect(sut, with: .select(nil), toDeliver: .selected(nil))
    }
    
    func test_select_shouldDeliverExchangeOnSelectExchange() throws {
        
        let exchange = makeExchangeFlow()
        let sut = makeSUT(exchange: exchange)
        
        let selected = try select(sut, with: .exchange)
        
        XCTAssertNoDiff(
            selected?.equatableProjection,
            .exchange(ObjectIdentifier(exchange))
        )
    }
    
    func test_select_shouldDeliverLatestOnSelectLatest() throws {
        
        let latestFlow = makeLatestFlow()
        let sut = makeSUT(latest: latestFlow)
        
        let selected = try select(sut, with: .latest(makeLatest()))
        
        XCTAssertNoDiff(
            selected?.equatableProjection,
            .latest(ObjectIdentifier(latestFlow))
        )
    }
    
    func test_select_shouldDeliverTemplatesOnSelectTemplates() throws {
        
        let templates = makeTemplatesFlow()
        let sut = makeSUT(templates: templates)
        
        let selected = try select(sut, with: .templates)
        
        XCTAssertNoDiff(
            selected?.equatableProjection,
            .templates(ObjectIdentifier(templates))
        )
    }
    
    func test_select_shouldDeliverObservableExchange() {
        
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let exchange = makeExchangeFlow()
        let sut = makeSUT(exchange: exchange)
        
        let observed = observed(sut, with: .select(.exchange), eventsCount: 2) {
            
            exchange.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.exchange(ObjectIdentifier(exchange))),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_select_shouldDeliverObservableExchange2() {
        
        let flowEvent = FlowEvent(isLoading: true, status: Status?.none)
        let exchange = makeExchangeFlow()
        let sut = makeSUT(exchange: exchange)
        
        let observed = observed(sut, with: .select(.exchange), eventsCount: 2) {
            
            exchange.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.exchange(ObjectIdentifier(exchange))),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_select_shouldDeliverObservableLatest() {
        
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let latestFlow = makeLatestFlow()
        let sut = makeSUT(latest: latestFlow)
        
        let observed = observed(sut, with: .select(.latest(makeLatest())), eventsCount: 2) {
            
            latestFlow.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.latest(ObjectIdentifier(latestFlow))),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_select_shouldDeliverObservableLatest2() {
        
        let flowEvent = FlowEvent(isLoading: true, status: Status?.none)
        let latestFlow = makeLatestFlow()
        let sut = makeSUT(latest: latestFlow)
        
        let observed = observed(sut, with: .select(.latest(makeLatest())), eventsCount: 2) {
            
            latestFlow.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.latest(ObjectIdentifier(latestFlow))),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_select_shouldDeliverObservableTemplates() {
        
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let templates = makeTemplatesFlow()
        let sut = makeSUT(templates: templates)
        
        let observed = observed(sut, with: .select(.templates), eventsCount: 2) {
            
            templates.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.templates(ObjectIdentifier(templates))),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_select_shouldDeliverObservableTemplates2() {
        
        let flowEvent = FlowEvent(isLoading: true, status: Status?.none)
        let templates = makeTemplatesFlow()
        let sut = makeSUT(templates: templates)
        
        let observed = observed(sut, with: .select(.templates), eventsCount: 2) {
            
            templates.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .selected(.templates(ObjectIdentifier(templates))),
            .flowEvent(flowEvent)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = OperationPickerFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>
    
    private func makeSUT(
        exchange: Flow? = nil,
        latest: Flow? = nil,
        templates: Flow? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(
            microServices: .init(
                makeExchange: { exchange ?? self.makeTemplatesFlow() },
                makeLatestFlow: { _ in latest ?? self.makeLatestFlow() },
                makeTemplates: { templates ?? self.makeTemplatesFlow() }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func select(
        _ sut: SUT,
        with item: OperationPickerItem<Latest>?,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> SUT.Item? {
        
        let event = observed(sut, with: .select(item), eventsCount: 1, on: action).first
        
        switch event {
        case let .selected(select):
            return select
            
        default:
            let message = "Expected selected event, but got \(String(describing: event)) instead."
            XCTFail(message, file: file, line: line)
            throw NSError(domain: message, code: -1)
        }
    }
    
    @discardableResult
    private func observed(
        _ sut: SUT,
        with effect: SUT.Effect,
        eventsCount: Int,
        on action: @escaping () -> Void = {}
    ) -> [SUT.Event] {
        
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = eventsCount
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        return events
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
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events.map(\.equatableProjection), expectedEvents.map(\.equatableProjection), file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
