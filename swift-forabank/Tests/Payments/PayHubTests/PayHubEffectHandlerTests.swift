//
//  PayHubEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubItem<Latest> {
    
    case exchange
    case latest(Latest)
    case templates
}

extension PayHubItem: Equatable where Latest: Equatable {}

enum PayHubEvent<Latest> {
    
    case loaded([PayHubItem<Latest>])
}

extension PayHubEvent: Equatable where Latest: Equatable {}

enum PayHubEffect: Equatable {
    
    case load
}

struct PayHubEffectHandlerMicroServices<Latest> {
    
    let load: Load
}

extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

final class PayHubEffectHandler<Latest> {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices<Latest>
}

extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            microServices.load {
                
                let latests = (try? $0.get()) ?? []
                let loaded = [.templates, .exchange] + latests.map(PayHubItem<Latest>.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Latest>
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
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadFailure() {
        
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([.templates, .exchange])) {
            
            loadPay.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeOnLoadEmptySuccess() {
        
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([.templates, .exchange])) {
            
            loadPay.complete(with: .success([]))
        }
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithOneOnLoadSuccessWithOne() {
        
        let latest = makeLatest()
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([.templates, .exchange, .latest(latest)])) {
            
            loadPay.complete(with: .success([latest]))
        }
    }
    
    func test_load_shouldDeliverTemplatesAndExchangeWithTwoOnLoadSuccessWithTwo() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([.templates, .exchange, .latest(latest1), .latest(latest2)])) {
            
            loadPay.complete(with: .success([latest1, latest2]))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubEffectHandler<Latest>
    private typealias LoadSpy = Spy<Void, SUT.MicroServices.LoadResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadPay = LoadSpy()
        let sut = SUT(
            microServices: .init(
                load: loadPay.process
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
    
    private func expect(
        _ sut: SUT,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
