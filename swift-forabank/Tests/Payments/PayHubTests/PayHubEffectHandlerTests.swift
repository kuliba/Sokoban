//
//  PayHubEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubItem<Latest, TemplatesFlow> {
    
    case exchange
    case latest(Latest)
    case templates(TemplatesFlow)
}

extension PayHubItem: Equatable where Latest: Equatable, TemplatesFlow: Equatable {}

enum PayHubEvent<Latest, TemplatesFlow> {
    
    case loaded([PayHubItem<Latest, TemplatesFlow>])
}

extension PayHubEvent: Equatable where Latest: Equatable, TemplatesFlow: Equatable {}

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

final class PayHubEffectHandler<Latest, TemplatesFlow> {
    
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
            let templates = microServices.makeTemplates()
            microServices.load {
                
                let latests = (try? $0.get()) ?? []
                let loaded = [.templates(templates), .exchange] + latests.map(Item.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
    
    typealias Item = PayHubItem<Latest, TemplatesFlow>
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Latest, TemplatesFlow>
    typealias Effect = PayHubEffect
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
        
        let delivered = try deliver(sut, with: .load) {
            
            loadPay.complete(with: .failure(anyError()))
        }
        
        XCTAssertNoDiff(delivered, .loaded([.templates(templates), .exchange]))
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadEmptySuccess() throws {
        
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let delivered = try deliver(sut, with: .load) {
            
            loadPay.complete(with: .success([]))
        }
        
        XCTAssertNoDiff(delivered, .loaded([.templates(templates), .exchange]))
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithOneOnLoadSuccessWithOne() throws {
        
        let latest = makeLatest()
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let delivered = try deliver(sut, with: .load) {
            
            loadPay.complete(with: .success([latest]))
        }
        
        XCTAssertNoDiff(delivered, .loaded([.templates(templates), .exchange, .latest(latest)]))
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithTwoOnLoadSuccessWithTwo() throws {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let templates = makeTemplatesFlow()
        let (sut, loadPay) = makeSUT(templates: templates)
        
        let delivered = try deliver(sut, with: .load) {
            
            loadPay.complete(with: .success([latest1, latest2]))
        }
        
        XCTAssertNoDiff(delivered, .loaded([.templates(templates), .exchange, .latest(latest1), .latest(latest2)]))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubEffectHandler<Latest, TemplatesFlow>
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
    
    private struct TemplatesFlow: Equatable {
        
        let value: String
    }
    
    private func makeTemplatesFlow(
    ) -> TemplatesFlow {
        
        return .init(value: anyMessage())
    }
    
    private func deliver(
        _ sut: SUT,
        with effect: SUT.Effect,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> SUT.Event {
        
        let exp = expectation(description: "wait for completion")
        var event: SUT.Event?
        
        sut.handleEffect(effect) {
            
            event = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        return try XCTUnwrap(event, file: file, line: line)
    }
}
