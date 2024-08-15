//
//  PayHubEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine

struct Node<Model> {
    
    let model: Model
    private let cancellables: Set<AnyCancellable>
    
    init(
        model: Model,
        cancellable: AnyCancellable
    ) {
        self.model = model
        self.cancellables = [cancellable]
    }
    
    init(
        model: Model,
        cancellables: Set<AnyCancellable>
    ) {
        self.model = model
        self.cancellables = cancellables
    }
}

extension Node: Equatable where Model: Equatable {}

protocol FlowEventEmitter<Status> {
    
    associatedtype Status
    
    var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> { get }
}

struct FlowEvent<Status> {
    
    let isLoading: Bool
    let status: Status?
}

extension FlowEvent: Equatable where Status: Equatable {}

enum PayHubItem<Latest, TemplatesFlow> {
    
    case exchange
    case latest(Latest)
    case templates(Node<TemplatesFlow>)
}

extension PayHubItem: Equatable where Latest: Equatable, TemplatesFlow: Equatable {}

enum PayHubEvent<Latest, Status, TemplatesFlow> {
    
    case flowEvent(FlowEvent<Status>)
    case loaded([PayHubItem<Latest, TemplatesFlow>])
}

extension PayHubEvent: Equatable where Latest: Equatable, Status: Equatable, TemplatesFlow: Equatable {}

enum PayHubEffect: Equatable {
    
    case load
}

struct PayHubEffectHandlerMicroServices<Latest, TemplatesFlow> {
    
    let load: Load
    let makeTemplates: MakeTemplates
}

extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias MakeTemplates = () -> TemplatesFlow
}

final class PayHubEffectHandler<Latest, Status, TemplatesFlow>
where TemplatesFlow: FlowEventEmitter,
      TemplatesFlow.Status == Status {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices<Latest, TemplatesFlow>
}

extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            let templatesNode = makeTemplatesNode(dispatch)
            
            microServices.load {
                
                let latests = (try? $0.get()) ?? []
                let loaded = [.templates(templatesNode), .exchange] + latests.map(Item.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
    
    typealias Item = PayHubItem<Latest, TemplatesFlow>
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Latest, Status, TemplatesFlow>
    typealias Effect = PayHubEffect
}

private extension PayHubEffectHandler {
    
    func makeTemplatesNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<TemplatesFlow> {
        
        let templates = microServices.makeTemplates()
        let cancellable = templates.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: templates, cancellable: cancellable)
    }
}

import XCTest

final class PayHubEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, loadPay) = makeSUT()
        
        XCTAssertEqual(loadPay.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadPay) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadPay.callCount, 1)
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadFailure() throws {
        
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let loaded = try load(sut, with: .load) {
            
            loadPay.complete(with: .failure(anyError()))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)), .exchange
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadEmptySuccess() throws {
        
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let loaded = try load(sut, with: .load) {
            
            loadPay.complete(with: .success([]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)), .exchange
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithOneOnLoadSuccessWithOne() throws {
        
        let latest = makeLatest()
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let loaded = try load(sut, with: .load) {
            
            loadPay.complete(with: .success([latest]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)), .exchange, .latest(latest)
        ])
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithTwoOnLoadSuccessWithTwo() throws {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let loaded = try load(sut, with: .load) {
            
            loadPay.complete(with: .success([latest1, latest2]))
        }
        
        XCTAssertNoDiff(loaded.map(\.equatableProjection), [
            .templates(ObjectIdentifier(templates)), .exchange, .latest(latest1), .latest(latest2)
        ])
    }
    
    func test_load_shouldDeliverObservableTemplates() {
        
        let templates = makeTemplatesFlow()
        let status = makeStatus()
        let flowEvent = FlowEvent(isLoading: false, status: status)
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadPay.complete(with: .failure(anyError()))
            templates.emit(flowEvent)
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([.templates(ObjectIdentifier(templates)), .exchange]),
            .flowEvent(flowEvent)
        ])
    }
    
    func test_load_shouldDeliverObservableTemplates2() {
        
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let observed = observed(sut, with: .load, eventsCount: 2) {
            
            loadPay.complete(with: .success([]))
            templates.emit(.init(isLoading: true, status: nil))
        }
        
        XCTAssertNoDiff(observed.map(\.equatableProjection), [
            .loaded([.templates(ObjectIdentifier(templates)), .exchange]),
            .flowEvent(.init(isLoading: true, status: nil))
        ])
    }

    // MARK: - Helpers
    
    private typealias SUT = PayHubEffectHandler<Latest, Status, TemplatesFlow>
    private typealias LoadSpy = Spy<Void, SUT.MicroServices.LoadResult>
    
    private func makeSUT(
        templates: TemplatesFlow? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadPay = LoadSpy()
        let sut = SUT(
            microServices: .init(
                load: loadPay.process,
                makeTemplates: { templates ?? self.makeTemplatesFlow() }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadPay, file: file, line: line)
        
        return (sut, loadPay)
    }
    
    private struct Latest: Equatable {
        
        let value: String
    }
    
    private func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
    
    private struct Status: Equatable {
        
        let value: String
    }
    
    private func makeStatus(
        _ value: String = anyMessage()
    ) -> Status {
        
        return .init(value: value)
    }
    
    private final class TemplatesFlow: FlowEventEmitter {
        
        typealias Event = FlowEvent<Status>
        
        private let subject = PassthroughSubject<Event, Never>()
        
        var eventPublisher: AnyPublisher<Event, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            subject.send(event)
        }
    }
    
    private func makeTemplatesFlow() -> TemplatesFlow {
        
        return .init()
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

extension PayHubItem where Latest: Equatable, TemplatesFlow: AnyObject {
    
    var equatableProjection: EquatableProjection {
        
        switch self {
        case .exchange:
            return .exchange
            
        case let .latest(latest):
            return .latest(latest)
            
        case let .templates(node):
            return .templates(ObjectIdentifier(node.model))
        }
    }
    
    enum EquatableProjection: Equatable {
        
        case exchange
        case latest(Latest)
        case templates(ObjectIdentifier)
    }
}

extension PayHubEvent where Latest: Equatable, Status: Equatable, TemplatesFlow: AnyObject {
    
    var equatableProjection: EquatableProjection {
        
        switch self {
        case let .flowEvent(flowEvent):
            return .flowEvent(flowEvent)
            
        case let .loaded(loaded):
            return .loaded(loaded.map(\.equatableProjection))
        }
    }
    
    enum EquatableProjection: Equatable {
        
        case flowEvent(FlowEvent<Status>)
        case loaded([PayHubItem<Latest, TemplatesFlow>.EquatableProjection])
    }
}
