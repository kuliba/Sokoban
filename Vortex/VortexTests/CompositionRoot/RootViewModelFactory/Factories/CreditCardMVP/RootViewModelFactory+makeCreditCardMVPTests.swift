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
    
    typealias ContentDomain = CreditCardMVPContentDomain
    typealias Content = RxViewModel<ContentDomain.State, ContentDomain.Event, ContentDomain.Effect>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case alert
        case failure
        case informer
        case approved
        case inReview
        case rejected
    }
    
    enum Navigation {
        
        case alert
        case informer
        case complete(Complete)
        case decision(Decision)
        
        struct Complete {
            
            let message: String
            let status: Status
            
            enum Status {
                
                case failure, inReview
            }
        }
        
        struct Decision {
            
            let status: Status
            
            enum Status {
                
                case approved, rejected
            }
        }
    }
}

// TODO: move to UI Mapping: map to PaymentCompletion.Status to reuse completion view
//extension CreditCardMVPDomain.Navigation.Complete.Status {
//
//    var paymentCompletionStatus: PaymentCompletion.Status {
//
//        switch self {
//        case .failure:  return .rejected
//        case .inReview: return .completed
//        }
//    }
//}

// TODO: extract to module
/// A namespace.
enum CreditCardMVPContentDomain {}
extension CreditCardMVPContentDomain {
    
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
    struct Draft {
        
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
                emitting: { $0.$state.compactMap(\.selectEvent) },
                dismissing: { content in { content.event(.dismissInformer) }}
            )
        )
    }
    
    // TODO: add @inlinable
    func makeCreditCardMVPContent(
        load: @escaping CreditCardMVPDomain.ContentDomain.Load,
        apply: @escaping CreditCardMVPDomain.ContentDomain.Apply
    ) -> CreditCardMVPDomain.Content {
        
        let draftableReducer = CreditCardMVPDomain.ContentDomain.DraftableReducer()
        let finalReducer = CreditCardMVPDomain.ContentDomain.FinalReducer()
        
        return .init(
            initialState: .pending,
            reduce: { state, event in // TODO: extract reducer
                
                var state = state
                var effect: CreditCardMVPDomain.ContentDomain.Effect?
                
                switch event {
                case let .apply(applicationEvent): // TODO: extract helper or even reducer - this is Form Domain, no other case is applicable
                    guard case var .completed(.draft(draft)) = state else { break }
                    
                    let (application, applicationEffect) = finalReducer.reduce(draft.application, applicationEvent)
                    draft.application = application
                    state = .completed(.draft(draft))
                    effect = applicationEffect.map { _ in .apply }
                    
                case let .load(loadEvent):
                    let (loadState, loadEffect) = draftableReducer.reduce(state, loadEvent)
                    state = loadState
                    effect = loadEffect.map { _ in .load }
                    
                case .dismissInformer:
                    state = .pending
                    // TODO: ?? state.success.application = .pending
                }
                
                return (state, effect)
            },
            handleEffect: { effect, dispatch in
                
                switch effect {
                case .apply:
                    apply { dispatch(.apply(.loaded($0))) }
                    
                case .load:
                    load { dispatch(.load(.loaded($0))) }
                }
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
            
        case .failure:
            completion(.complete(.init(
                message: .failure,
                status: .failure
            )))
            
        case .informer:
            completion(.informer)
            
        case .approved:
            completion(.decision(.init(status: .approved)))
            
        case .inReview:
            completion(.complete(.init(
                message: .inReview,
                status: .inReview
            )))
            
        case .rejected:
            completion(.decision(.init(status: .rejected)))
        }
    }
}

private extension String {
    
    static let failure = "Что-то пошло не так...\nПопробуйте позже."
    
    static let inReview = "Ожидайте рассмотрения Вашей заявки\nРезультат придет в Push/смс\nПримерное время рассмотрения заявки 10 минут."
}

extension CreditCardMVPDomain.ContentDomain.State {
    
    var selectEvent: FlowEvent<CreditCardMVPDomain.Select, Never>? {
        
        select.map { .select($0) }
    }
    
    var select: CreditCardMVPDomain.Select? {
        
        switch self {
        case .completed(.approved):
            return .approved
            
        case let .completed(.draft(draft)):
            switch draft.application {
            case .completed(.approved):
                return .approved
                
            case .completed(.inReview):
                return .inReview
                
            case .completed(.rejected):
                return .rejected
                
            case let .failure(failure):
                switch failure.type {
                case .alert:    return .failure
                case .informer: return .informer
                }
                
            case .loading, .pending:
                return nil
            }
            
        case .completed(.inReview):
            return .inReview
            
        case .completed(.rejected):
            return .rejected
            
        case let .failure(failure):
            switch failure.type {
            case .alert:    return .alert
            case .informer: return .informer
            }
            
        case .loading, .pending:
            return nil
        }
    }
    
    // TODO: extract to extension in UI mapping
    
    // var isLoading: Bool { application.isLoading || status.isLoading }
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeCreditCardMVPTests: RootViewModelFactoryTests {
    
    func test_shouldCallLoadInitially() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldNotCallApplyInitially() {
        
        let (sut, _, applySpy) = makeSUT()
        
        XCTAssertEqual(applySpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldHaveNoNavigationInitially() {
        
        let (sut, _,_) = makeSUT()
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - alert
    
    func test_shouldShowAlert_onAlertFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: alert())
        
        XCTAssertTrue(sut.flow.isShowingAlert)
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onInformerFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: informer())
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldRemoveInformer_onDismiss() {
        
        let (sut, loadSpy, _) = makeSUT()
        loadSpy.complete(with: informer())
        XCTAssertTrue(sut.flow.isShowingInformer)
        
        sut.flow.event(.dismiss)
        
        XCTAssertFalse(sut.content.hasConnectivityError)
    }
    
    // MARK: - draft (form)
    
    func test_shouldShowDraft_onDraftStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: draft())
        
        XCTAssertTrue(sut.content.hasDraft)
    }
    
    func test_shouldNotNavigate_onDraftStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: draft())
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNavigateToFailure_onDraftApplyAlertFailure() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: alert())
        
        XCTAssertTrue(sut.flow.isShowingFailure)
    }
    
    func test_shouldShowInformer_onDraftApplyInformerFailure() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: informer())
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldRemoveInformer_onDismiss_onDraftApply() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        sut.content.event(.apply(.load))
        applySpy.complete(with: informer())
        XCTAssertTrue(sut.flow.isShowingInformer) // flow.isShowingInformer or what is showing??
        
        sut.flow.event(.dismiss)
        
        XCTAssertFalse(sut.content.hasConnectivityError)
    }
    
    func test_shouldNavigateToApproved_onApprovedApplyStatus() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: .approved)
        
        XCTAssertTrue(sut.flow.isShowingApproved)
    }
    
    func test_shouldNavigateToRejected_onInReviewApplyStatus() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: .inReview)
        
        XCTAssertTrue(sut.flow.isShowingInReview)
    }
    
    func test_shouldNavigateToRejected_onRejectedApplyStatus() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: .rejected)
        
        XCTAssertTrue(sut.flow.isShowingRejected)
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: .approved)
        
        XCTAssertTrue(sut.flow.isShowingApproved)
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: .inReview)
        
        XCTAssertTrue(sut.flow.isShowingInReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: .rejected)
        
        XCTAssertTrue(sut.flow.isShowingRejected)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = CreditCardMVPDomain
    private typealias ContentDomain = Domain.ContentDomain
    
    private typealias SUT = Domain.Binder
    private typealias LoadSpy = Spy<Void, ContentDomain.DraftableStatus, ContentDomain.Failure>
    private typealias ApplySpy = Spy<Void, ContentDomain.FinalStatus, ContentDomain.Failure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        applySpy: ApplySpy
    ) {
        let (factory, _,_) = super.makeSUT(file: file, line: line)
        let loadSpy = LoadSpy()
        let applySpy = ApplySpy()
        let content = factory.makeCreditCardMVPContent(
            load: loadSpy.process,
            apply: applySpy.process
        )
        let sut = factory.makeCreditCardMVPBinder(content: content)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(applySpy, file: file, line: line)
        
        return (sut, loadSpy, applySpy)
    }
    
    private func alert() -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: anyMessage(), type: .alert)
    }
    
    private func informer() -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: anyMessage(), type: .informer)
    }
    
    private func draft(
        application: ContentDomain.Draft.ApplicationState = .pending
    ) -> ContentDomain.DraftableStatus {
        
        return .draft(.init(application: application))
    }
}

// MARK: - DSL

extension CreditCardMVPDomain.Content {
    
    var hasConnectivityError: Bool {
        
        guard case let .failure(failure) = state else { return false }
        return failure.type == .alert
    }
    
    var hasDraft: Bool {
        
        guard case .completed(.draft) = state else { return false }
        return true
    }
}

extension CreditCardMVPDomain.Flow {
    
    var isShowingAlert: Bool {
        
        guard case .alert = state.navigation else { return false }
        return true
    }
    
    var isShowingFailure: Bool {
        
        guard case let .complete(complete) = state.navigation
        else { return false }
        
        return complete.status == .failure
    }
    
    var isShowingInformer: Bool {
        
        guard case .informer = state.navigation else { return false }
        return true
    }
    
    var isShowingApproved: Bool {
        
        guard case let .decision(decision) = state.navigation else { return false }
        return decision.status == .approved
    }
    
    var isShowingInReview: Bool {
        
        guard case let .complete(complete) = state.navigation
        else { return false }
        
        return complete.status == .inReview
    }
    
    var isShowingRejected: Bool {
        
        guard case let .decision(decision) = state.navigation else { return false }
        return decision.status == .rejected
    }
}
