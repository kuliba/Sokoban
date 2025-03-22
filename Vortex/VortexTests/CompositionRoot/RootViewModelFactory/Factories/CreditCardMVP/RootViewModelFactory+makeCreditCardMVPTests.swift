//
//  RootViewModelFactory+makeCreditCardMVPTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.03.2025.
//

import Combine
import CreditCardMVPCore
import FlowCore
import RxViewModel
import StateMachines

/// A namespace.
enum CreditCardMVPDomain {}

extension CreditCardMVPDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case alert
        case informer
        case approved
        case inReview
        case rejected
    }
    
    enum Navigation {
        
        case alert
        case informer
        case approved
        case inReview
        case rejected
    }
}

extension CreditCardMVPDomain {
    
    // MARK: - Content Domain
    
    typealias State = StateMachines.LoadState<ApplicationStatus, ApplicationFailure>
    
    enum Event {
        
        case dismissInformer
        case load(LoadEvent)
        
        typealias LoadEvent = StateMachines.LoadEvent<ApplicationStatus, ApplicationFailure>
    }
    
    typealias Effect = StateMachines.LoadEffect
    
    // MARK: - Content Logic
    
    typealias LoadReducer = StateMachines.LoadReducer<ApplicationStatus, ApplicationFailure>
    typealias LoadEffectHandler = StateMachines.LoadEffectHandler<ApplicationStatus, ApplicationFailure>
    
    // MARK: - Content Types
    
    typealias ApplicationFailure = LoadFailure<Failure>
    
    enum ApplicationStatus {
        
        case approved, draft, inReview, rejected
    }
    
    enum Failure {
        
        case alert, informer
    }
    
    typealias LoadResult = Result<ApplicationStatus, ApplicationFailure>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

extension RootViewModelFactory {
    
    // TODO: add @inlinable
    func makeCreditCardMVPBinder(
        content: CreditCardMVPDomain.Content
    ) -> CreditCardMVPDomain.Binder {
        
        content.event(.load(.load))
        
        return composeBinder(
            content: content,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { $0.$state.compactMap(\.select) },
                dismissing: { content in { content.event(.dismissInformer) }}
            )
        )
    }
    
    // TODO: add @inlinable
    func makeCreditCardMVPContent(
        load: @escaping CreditCardMVPDomain.Load
    ) -> CreditCardMVPDomain.Content {
        
        let reducer = CreditCardMVPDomain.LoadReducer()
        let effectHandler = CreditCardMVPDomain.LoadEffectHandler(load: load)
        
        return .init(
            initialState: .pending,
            reduce: { state, event in // TODO: extract reducer
                
                var state = state
                var effect: CreditCardMVPDomain.Effect?
                
                switch event {
                case let .load(loadEvent):
                    (state, effect) = reducer.reduce(state, loadEvent)
                    
                case .dismissInformer:
                    state = .pending
                }
                
                return (state, effect)
            },
            handleEffect: { effect, dispatch in
                
                effectHandler.handleEffect(effect) { dispatch(.load($0)) }
            },
            scheduler: schedulers.main
        )
    }
    
    // TODO: add @inlinable
    func getNavigation(
        select: CreditCardMVPDomain.Select,
        notify: @escaping CreditCardMVPDomain.Notify,
        completion: @escaping (CreditCardMVPDomain.Navigation) -> Void
    ) {
        switch select {
        case .alert:
            completion(.alert)
        case .informer:
            completion(.informer)
        case .approved:
            completion(.approved)
        case .inReview:
            completion(.inReview)
        case .rejected:
            completion(.rejected)
        }
    }
}

extension CreditCardMVPDomain.State {
    
    var select: FlowEvent<CreditCardMVPDomain.Select, Never>? {
        
        switch self {
        case let .completed(completed):
            switch completed {
            case .approved:
                return .select(.approved)
                
            case .draft:
                return nil
                
            case .inReview:
                return .select(.inReview)
                
            case .rejected:
                return .select(.rejected)
            }
            
        case let .failure(failure):
            switch failure.type {
            case .alert:
                return .select(.alert)
                
            case .informer:
                return .select(.informer)
            }
            
        case .loading, .pending:
            return nil
        }
    }
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeCreditCardMVPTests: RootViewModelFactoryTests {
    
    func test_shouldCallLoadInitially() {
        
        let (sut, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldHaveNoNavigationInitially() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - alert
    
    func test_shouldShowAlert_onServerError() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .init(message: anyMessage(), type: .alert))
        
        XCTAssertTrue(sut.flow.isShowingAlert)
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onConnectivityError() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .init(message: anyMessage(), type: .informer))
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldShowInformer_onUnknownStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .init(message: anyMessage(), type: .informer))
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldRemoveInformer_onDismiss() {
        
        let (sut, loadSpy) = makeSUT()
        loadSpy.complete(with: .init(message: anyMessage(), type: .informer))
        XCTAssertTrue(sut.flow.isShowingInformer)
        
        sut.flow.event(.dismiss)
        
        XCTAssertFalse(sut.content.hasConnectivityError)
    }
    
    // MARK: - form
    
    func test_shouldShowForm_onDraftStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .draft)
        
        XCTAssertTrue(sut.content.hasForm)
    }
    
    func test_shouldNotNavigate_onDraftStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .draft)
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .approved)
        
        XCTAssertTrue(sut.flow.isShowingApproved)
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .inReview)
        
        XCTAssertTrue(sut.flow.isShowingInReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let (sut, loadSpy) = makeSUT()
        
        loadSpy.complete(with: .rejected)
        
        XCTAssertTrue(sut.flow.isShowingRejected)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CreditCardMVPDomain.Binder
    private typealias LoadSpy = Spy<Void, CreditCardMVPDomain.ApplicationStatus, CreditCardMVPDomain.ApplicationFailure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let (factory, _,_) = super.makeSUT(file: file, line: line)
        let loadSpy = LoadSpy()
        let content = factory.makeCreditCardMVPContent(load: loadSpy.process)
        let sut = factory.makeCreditCardMVPBinder(content: content)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
    }
}

// MARK: - DSL

extension CreditCardMVPDomain.Content {
    
    var hasConnectivityError: Bool {
        
        guard case let .failure(failure) = state else { return false }
        return failure.type == .alert
    }
    
    var hasForm: Bool {
        
        guard case let .completed(status) = state else { return false }
        return status == .draft
    }
}

extension CreditCardMVPDomain.Flow {
    
    var isShowingAlert: Bool {
        
        guard case .alert = state.navigation else { return false }
        return true
    }
    
    var isShowingInformer: Bool {
        
        guard case .informer = state.navigation else { return false }
        return true
    }
    
    var isShowingApproved: Bool {
        
        guard case .approved = state.navigation else { return false }
        return true
    }
    
    var isShowingInReview: Bool {
        
        guard case .inReview = state.navigation else { return false }
        return true
    }
    
    var isShowingRejected: Bool {
        
        guard case .rejected = state.navigation else { return false }
        return true
    }
}
