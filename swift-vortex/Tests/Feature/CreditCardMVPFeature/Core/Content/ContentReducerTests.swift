//
//  ContentReducerTests.swift
//  
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

/// A namespace.
enum ContentDomain {}

extension ContentDomain {
    
    // MARK: - Domain
    
    typealias State = StateMachines.LoadState<DraftableStatus, Failure>
    
    enum Event {
        
        case apply(ApplyEvent)
        case dismissInformer
        case load(LoadEvent)
        
        typealias ApplyEvent = StateMachines.LoadEvent<FinalStatus, Failure>
        typealias LoadEvent = StateMachines.LoadEvent<DraftableStatus, Failure>
    }
    
    enum Effect {
        
        case apply, load
    }
    
    // MARK: - Content Types
    
    typealias DraftableStatus = ApplicationStatus<Draft>
    typealias FinalStatus = ApplicationStatus<Never>
    
    enum ApplicationStatus<Draft> {
        
        case approved, inReview, rejected
        case draft(Draft)
    }
    
    typealias Failure = LoadFailure<FailureType>
    
    /// `Form`
    struct Draft: Equatable {
        
        var application: ApplicationState = .pending
        
        typealias ApplicationState = StateMachines.LoadState<FinalStatus, Failure>
    }
    
    enum FailureType {
        
        case alert, informer
    }
    
    // MARK: - Content Logic
    
    typealias DraftableReducer = StateMachines.LoadReducer<DraftableStatus, Failure>
    typealias FinalReducer = StateMachines.LoadReducer<FinalStatus, Failure>
    
    // MARK: - Closures
    
    typealias LoadResult = Result<DraftableStatus, Failure>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias ApplyResult = Result<FinalStatus, Failure>
    typealias ApplyCompletion = (ApplyResult) -> Void
    typealias Apply = (@escaping ApplyCompletion) -> Void
}

extension ContentDomain.ApplicationStatus: Equatable where Draft: Equatable {}

final class ContentReducer {
    
    init() {}
}

extension ContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
//        switch event {
//        case let .apply(applicationEvent):
//            break
//        }
        
        return (state, effect)
    }
}

extension ContentReducer {
    
    typealias State = ContentDomain.State
    typealias Event = ContentDomain.Event
    typealias Effect = ContentDomain.Effect
}

import CreditCardMVPCore
import XCTest

final class ContentReducerTests: XCTestCase {
    
    // MARK: - dismissInformer

    func test_dismissInformer_shouldNotChangeCompletedApprovedState() {
    
        assert(.completed(.approved), event: .dismissInformer)
    }

    func test_dismissInformer_shouldNotDeliverEffect_onCompletedApprovedState() {
    
        assert(.completed(.approved), event: .dismissInformer, delivers: nil)
    }

    func test_dismissInformer_shouldNotChangeCompletedInReviewState() {
    
        assert(.completed(.inReview), event: .dismissInformer)
    }

    func test_dismissInformer_shouldNotDeliverEffect_onCompletedInReviewState() {
    
        assert(.completed(.inReview), event: .dismissInformer, delivers: nil)
    }

    func test_dismissInformer_shouldNotChangeCompletedRejectedState() {
    
        assert(.completed(.rejected), event: .dismissInformer)
    }

    func test_dismissInformer_shouldNotDeliverEffect_onCompletedRejectedState() {
    
        assert(.completed(.rejected), event: .dismissInformer, delivers: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = ContentReducer
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
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        event: Event,
        updateStateToExpected: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        event: Event,
        delivers expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect): (State, Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
