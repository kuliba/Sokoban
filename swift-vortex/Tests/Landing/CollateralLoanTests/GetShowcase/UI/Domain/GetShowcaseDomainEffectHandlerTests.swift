//
//  GetShowcaseDomainEffectHandlerTests.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

@testable import CollateralLoanLandingGetShowcaseUI
import XCTest
import Combine

final class GetShowcaseDomainEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallEvent() {
        
        let (sut, spy, _) = makeSUT()
        sut.handleEffect(.load, dispatch: { _ in })
        
        XCTAssertEqual(spy.receivedEvents, [])
    }
    
    func test_handleEffect_shouldLoadithLoadEvent() {
        
        let (sut, _, loadSpy) = makeSUT()
        
        expect(
            sut,
            with: .load,
            toDeliver: .loaded(.failure(.init())),
            on: {
                
                loadSpy.complete(with: .failure(.init()))
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetShowcaseDomain.EffectHandler
    private typealias Event = GetShowcaseDomain.Event
    private typealias Dispatch = (Event) -> Void
    private typealias Load = (@escaping Completion) -> Void
    private typealias Completion = (GetShowcaseDomain.Result) -> Void
    private typealias LoadSpy = SpyDispatch<Void, GetShowcaseDomain.Result>
    
    private func makeSUT() -> (
        sut: SUT,
        spy: Spy,
        loadSpy: LoadSpy
    ) {
        let spy = Spy()
        let loadSpy = LoadSpy()
        let sut = SUT(load: loadSpy.process(completion:))

        return (sut, spy, loadSpy)
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private final class Spy {
        
        private let subject = PassthroughSubject<State, Never>()
        
        private(set) var receivedEvents = [Event]()
        
        var statePublisher: AnyPublisher<State, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func event(_ event: Event) {
            
            self.receivedEvents.append(event)
        }
        
        func send(_ state: State) {
            
            subject.send(state)
        }
    }
}
