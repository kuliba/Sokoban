//
//  PayHubEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import PayHub
import XCTest

final class PayHubEffectHandlerTests: PayHubTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() throws {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.handleEffect(.load) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadFailure() throws {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let loaded = try load(sut, with: .load) {
            
            loadSpy.complete(with: .failure(anyError()))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)),
            .exchange(ObjectIdentifier(exchange))
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadEmptySuccess() throws {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let loaded = try load(sut, with: .load) {
            
            loadSpy.complete(with: .success([]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)),
            .exchange(ObjectIdentifier(exchange))
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithOneLatestOnLoadSuccessWithOne() throws {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (latest, latestFlow) = (makeLatest(), makeLatestFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            latest: [latest: latestFlow],
            templates: templates
        )
        
        let loaded = try load(sut, with: .load) {
            
            loadSpy.complete(with: .success([latest]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)),
            .exchange(ObjectIdentifier(exchange)),
            .latest(ObjectIdentifier(latestFlow))
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithTwoLatestOnLoadSuccessWithTwo() throws {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let (latestFlow1, latestFlow2) = (makeLatestFlow(), makeLatestFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            latest: [
                latest1: latestFlow1,
                latest2: latestFlow2
            ],
            templates: templates
        )
        
        let loaded = try load(sut, with: .load) {
            
            loadSpy.complete(with: .success([latest1, latest2]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)),
            .exchange(ObjectIdentifier(exchange)),
            .latest(ObjectIdentifier(latestFlow1)),
            .latest(ObjectIdentifier(latestFlow2))
        ])
    }
    
    func test_load_shouldDeliverObservableTemplates() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .failure(anyError()))
            templates.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange))
            ]),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_load_shouldDeliverObservableTemplates2() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .success([]))
            templates.emit(.init(isLoading: true, status: nil))
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange))
            ]),
            .flowEvent(.init(isLoading: true, status: nil))
        ])
    }
    
    func test_load_shouldDeliverObservableExchange() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .failure(anyError()))
            exchange.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange))
            ]),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_load_shouldDeliverObservableExchange2() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .success([]))
            exchange.emit(.init(isLoading: true, status: nil))
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange))
            ]),
            .flowEvent(.init(isLoading: true, status: nil))
        ])
    }
    
    func test_load_shouldDeliverObservableLatestFlow() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (latest, latestFlow) = (makeLatest(), makeLatestFlow())
        let flowEvent = FlowEvent(isLoading: false, status: makeStatus())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            latest: [latest: latestFlow],
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .success([latest]))
            latestFlow.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange)),
                .latest(ObjectIdentifier(latestFlow))
            ]),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_load_shouldDeliverObservableLatestFlow2() {
        
        let (exchange, templates) = (makeTemplatesFlow(), makeExchangeFlow())
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let (latestFlow1, latestFlow2) = (makeLatestFlow(), makeLatestFlow())
        let (sut, loadSpy) = makeSUT(
            exchange: exchange,
            latest: [
                latest1: latestFlow1,
                latest2: latestFlow2
            ],
            templates: templates
        )
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadSpy.complete(with: .success([latest1, latest2]))
            latestFlow2.emit(.init(isLoading: true, status: nil))
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([
                .templates(ObjectIdentifier(templates)),
                .exchange(ObjectIdentifier(exchange)),
                .latest(ObjectIdentifier(latestFlow1)),
                .latest(ObjectIdentifier(latestFlow2))
            ]),
            .flowEvent(.init(isLoading: true, status: nil))
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubEffectHandler<Exchange, Latest, LatestFlow, Templates>
    private typealias LoadSpy = Spy<Void, SUT.MicroServices.LoadResult>
    
    private func makeSUT(
        exchange: Flow? = nil,
        latest: [Latest: LatestFlow] = [:],
        templates: Flow? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let sut = SUT(
            microServices: .init(
                load: loadSpy.process,
                makeExchange: { exchange ?? self.makeTemplatesFlow() },
                makeLatestFlow: {
                    
                    return latest[$0] ?? { fatalError() }()
                },
                makeTemplates: { templates ?? self.makeTemplatesFlow() }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
    }
    
    @discardableResult
    private func load(
        _ sut: SUT,
        with effect: SUT.Effect,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [SUT.Item] {
        
        let event = observed(sut, with: effect, eventsCount: 1, on: action).first
        
        switch event {
        case let .loaded(loaded):
            return loaded
            
        default:
            let message = "Expected loaded event, but got \(String(describing: event)) instead."
            XCTFail(message, file: file, line: line)
            throw NSError(domain: message, code: -1)
        }
    }
    
    @discardableResult
    private func observed(
        _ sut: SUT,
        with effect: SUT.Effect,
        eventsCount: Int,
        on action: @escaping () -> Void
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
}
