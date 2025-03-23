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

extension ContentDomain.State {
    
    var draft: ContentDomain.Draft? {
        
        get {
            guard case let .completed(.draft(draft)) = self else { return nil }
            return draft
        }
        
        set(newValue) { 
            
            guard let newValue else { return }
            self = .completed(.draft(newValue))
        }
    }
}

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
        
        switch event {
        case let .apply(applicationEvent):
            break
            
        case .dismissInformer:
            dismissInformer(&state)
            
        case let .load(loadEvent):
            reduce(&state, &effect, with: loadEvent)
        }
        
        return (state, effect)
    }
}

private extension ContentReducer {
    
    func dismissInformer(
        _ state: inout State
    ) {
        switch state {
        case let .failure(failure) where failure.type == .informer:
            state = .pending
            
        case var .completed(.draft(draft)) where draft.application.failure?.type == .informer:
            
            draft.application = .pending
            state = .completed(.draft(draft))
            
        default:
            return
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with loadEvent: Event.LoadEvent
    ) {
        
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
    
    func test_dismissInformer_shouldNotChangeApprovedState() {
        
        assert(.completed(.approved), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onApprovedState() {
        
        assert(.completed(.approved), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeInReviewState() {
        
        assert(.completed(.inReview), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onInReviewState() {
        
        assert(.completed(.inReview), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeRejectedState() {
        
        assert(.completed(.rejected), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onRejectedState() {
        
        assert(.completed(.rejected), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationApprovedState() {
        
        assert(makeDraftState(application: .completed(.approved)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationApprovedState() {
        
        assert(makeDraftState(application: .completed(.approved)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationInReviewState() {
        
        assert(makeDraftState(application: .completed(.inReview)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationInReviewState() {
        
        assert(makeDraftState(application: .completed(.inReview)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationRejectedState() {
        
        assert(makeDraftState(application: .completed(.rejected)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationRejectedState() {
        
        assert(makeDraftState(application: .completed(.rejected)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationAlertFailureState() {
        
        assert(makeDraftState(application: .failure(makeFailure(type: .alert))), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationAlertFailureState() {
        
        assert(makeDraftState(application: .failure(makeFailure(type: .alert))), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationInformerFailureState() {
        
        assert(makeDraftState(application: .failure(makeFailure(type: .informer))), event: .dismissInformer) {
            
            $0 = .completed(.draft(.init(application: .pending)))
        }
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationInformerFailureState() {
        
        assert(makeDraftState(application: .failure(makeFailure(type: .informer))), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationLoadingNilState() {
        
        assert(makeDraftState(application: .loading(nil)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationLoadingNilState() {
        
        assert(makeDraftState(application: .loading(nil)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationLoadingApprovedState() {
        
        assert(makeDraftState(application: .loading(.approved)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationLoadingApprovedState() {
        
        assert(makeDraftState(application: .loading(.approved)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationLoadingInReviewState() {
        
        assert(makeDraftState(application: .loading(.inReview)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationLoadingInReviewState() {
        
        assert(makeDraftState(application: .loading(.inReview)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationLoadingRejectedState() {
        
        assert(makeDraftState(application: .loading(.rejected)), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationLoadingRejectedState() {
        
        assert(makeDraftState(application: .loading(.rejected)), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeDraftApplicationPendingState() {
        
        assert(makeDraftState(application: .pending), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onDraftApplicationPendingState() {
        
        assert(makeDraftState(application: .pending), event: .dismissInformer, delivers: nil)
    }
        
    // continue
    func test_dismissInformer_shouldNotChangeAlertFailureState() {
        
        assert(makeFailureState(type: .alert), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onAlertFailureState() {
        
        assert(makeFailureState(type: .alert), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldChangeInformerFailureState() {
        
        assert(makeFailureState(type: .informer), event: .dismissInformer) {
            
            $0 = .pending
        }
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onInformerFailureState() {
        
        assert(makeFailureState(type: .informer), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeLoadingNilState() {
        
        assert(.loading(nil), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onLoadingNilState() {
        
        assert(.loading(nil), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeLoadingApprovedState() {
        
        assert(.loading(.approved), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onLoadingApprovedState() {
        
        assert(.loading(.approved), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeLoadingInReviewState() {
        
        assert(.loading(.inReview), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onLoadingInReviewState() {
        
        assert(.loading(.inReview), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeLoadingRejectedState() {
        
        assert(.loading(.rejected), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onLoadingRejectedState() {
        
        assert(.loading(.rejected), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangeLoadingDraftState() {
        
        assert(.loading(.draft(.init(application: .pending))), event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onLoadingDraftState() {
        
        assert(.loading(.draft(.init(application: .pending))), event: .dismissInformer, delivers: nil)
    }
    
    func test_dismissInformer_shouldNotChangePendingState() {
        
        assert(.pending, event: .dismissInformer)
    }
    
    func test_dismissInformer_shouldNotDeliverEffect_onPendingState() {
        
        assert(.pending, event: .dismissInformer, delivers: nil)
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
    
    private func makeDraftState(
        application: ContentDomain.Draft.ApplicationState
    ) -> State {
        
        return .completed(.draft(.init(application: application)))
    }
    
    private func makeFailureState(
        message: String =  anyMessage(),
        type: ContentDomain.FailureType
    ) -> State {
        
        return .failure(makeFailure(message: message, type: type))
    }
    
    private func makeFailure(
        message: String =  anyMessage(),
        type: ContentDomain.FailureType
    ) -> ContentDomain.Failure {
        
        return .init(message: message, type: type)
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
