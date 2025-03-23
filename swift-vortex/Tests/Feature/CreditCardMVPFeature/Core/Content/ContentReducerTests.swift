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
    
    typealias State = StateMachines.LoadState<DraftableStatus, Failure>
    
    enum Event {
        
        case apply(ApplyEvent)
        case dismissInformer
        case load(LoadEvent)
        
        typealias ApplyEvent = StateMachines.LoadEvent<FinalStatus, Failure>
        typealias LoadEvent = StateMachines.LoadEvent<DraftableStatus, Failure>
    }
    
    enum Effect: Equatable {
        
        case apply(LoadEffect)
        case load(LoadEffect)
    }
    
    // MARK: - Types
    
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
}

extension ContentDomain.ApplicationStatus: Equatable where Draft: Equatable {}

final class ContentReducer {
    
    private let applyReduce: ApplyReduce
    private let loadReduce: LoadReduce
    
    init(
        applyReduce: @escaping ApplyReduce,
        loadReduce: @escaping LoadReduce
    ) {
        self.applyReduce = applyReduce
        self.loadReduce = loadReduce
    }
    
    typealias ApplyReduce = (ApplyState, ApplyEvent) -> (ApplyState, LoadEffect?)
    typealias ApplyState = ContentDomain.Draft.ApplicationState
    typealias ApplyEvent = ContentDomain.Event.ApplyEvent
    
    typealias LoadReduce = (State, LoadEvent) -> (State, LoadEffect?)
    typealias LoadEvent = ContentDomain.Event.LoadEvent
}

extension ContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .apply(applyEvent):
            reduce(&state, &effect, with: applyEvent)
            
        case .dismissInformer:
            dismissInformer(&state)
            
        case let .load(loadEvent):
            reduce(&state, &effect, with: loadEvent)
        }
        
        return (state, effect)
    }
}

extension ContentReducer {
    
    typealias State = ContentDomain.State
    typealias Event = ContentDomain.Event
    typealias Effect = ContentDomain.Effect
}

private extension ContentReducer {
    
    func dismissInformer(
        _ state: inout State
    ) {
        if state.failure?.type == .informer {
            state = .pending
        } else if state.draft?.application.failure?.type == .informer {
            state.draft?.application = .pending
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with applyEvent: Event.ApplyEvent
    ) {
        guard let draft = state.draft else { return }
        
        let (application, applyEffect) = applyReduce(draft.application, applyEvent)
        state.draft?.application = application
        effect = applyEffect.map { .apply($0) }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with loadEvent: Event.LoadEvent
    ) {
        let (reducedState, reducedEffect) = loadReduce(state, loadEvent)
        state = reducedState
        effect = reducedEffect.map { .load($0) }
    }
}

private extension ContentDomain.State {
    
    var draft: ContentDomain.Draft? {
        
        get {
            guard case let .completed(.draft(draft)) = self else { return nil }
            return draft
        }
        
        set(newValue) {
            
            guard let newValue,
                  case .completed(.draft) = self
            else { return }
            self = .completed(.draft(newValue))
        }
    }
}

import CreditCardMVPCore
import XCTest

final class ContentReducerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, applySpy, loadSpy) = makeSUT()
        
        XCTAssertEqual(applySpy.callCount, 0)
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - apply
    
    func test_apply_shouldCallApplyReduce() {
        
        let (sut, applySpy, _) = makeSUT()
        
        _ = sut.reduce(makeDraftState(application: .pending), .apply(.load))
        
        XCTAssertEqual(applySpy.callCount, 1)
    }
    
    func test_apply_shouldNotChangeApprovedState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.approved), event: .apply(.load))
    }
    
    func test_apply_shouldNotDeliverEffect_onApprovedState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.approved), event: .apply(.load), delivers: nil)
    }
    
    func test_apply_shouldNotChangeInReviewState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.inReview), event: .apply(.load))
    }
    
    func test_apply_shouldNotDeliverEffect_onInReviewState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.approved), event: .apply(.load), delivers: nil)
    }
    
    func test_apply_shouldNotChangeRejectedState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.rejected), event: .apply(.load))
    }
    
    func test_apply_shouldNotDeliverEffect_onRejectedState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, .completed(.approved), event: .apply(.load), delivers: nil)
    }
    
    func test_apply_shouldChangeApplicationState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, makeDraftState(application: .pending), event: .apply(.load)) {
            
            $0 = .completed(.draft(.init(application: .completed(.inReview))))
        }
    }
    
    func test_apply_shouldDeliverApplyReduceEffect_onDraftState() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), .load))
        
        assert(sut: sut, makeDraftState(application: .pending), event: .apply(.load), delivers: .apply(.load))
    }
    
    func test_apply_shouldDeliverApplyReduceNilEffect() {
        
        let (sut, _,_) = makeSUT(applyStub: (.completed(.inReview), nil))
        
        assert(sut: sut, .pending, event: .apply(.load), delivers: nil)
    }
    
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
    
    // MARK: - load
    
    func test_load_shouldCallLoadReduce() {
        
        let (sut, _, loadSpy) = makeSUT()
        
        _ = sut.reduce(makeDraftState(application: .pending), .load(.load))
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldDeliverLoadReduceState() {
        
        let state = makeDraftState(application: .completed(.inReview))
        let (sut, _,_) = makeSUT(stub: (state, nil))
        
        assert(sut: sut, .pending, event: .load(.load)) { $0 = state }
    }
    
    func test_load_shouldDeliverLoadReduceEffect() {
        
        let state = makeDraftState(application: .completed(.inReview))
        let (sut, _,_) = makeSUT(stub: (state, .load))
        
        assert(sut: sut, .pending, event: .load(.load), delivers: .load(.load))
    }
    
    func test_load_shouldDeliverLoadReduceNilEffect() {
        
        let state = makeDraftState(application: .completed(.inReview))
        let (sut, _,_) = makeSUT(stub: (state, nil))
        
        assert(sut: sut, .pending, event: .load(.load), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentReducer
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias LoadSpy = CallSpy<(State, Event.LoadEvent), (State, LoadEffect?)>
    private typealias ApplySpy = CallSpy<(SUT.ApplyState, Event.ApplyEvent), (SUT.ApplyState, LoadEffect?)>
    
    private func makeSUT(
        applyStub: (SUT.ApplyState, LoadEffect?) = (.loading(nil), nil),
        stub loadStub: (State, LoadEffect?) = (.loading(nil), nil),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        applySpy: ApplySpy,
        loadSpy: LoadSpy
    ) {
        let applySpy = ApplySpy(stubs: [applyStub])
        let loadSpy = LoadSpy(stubs: [loadStub])
        let sut = SUT(applyReduce: applySpy.call, loadReduce: loadSpy.call)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(applySpy, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, applySpy, loadSpy)
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
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
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
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
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
