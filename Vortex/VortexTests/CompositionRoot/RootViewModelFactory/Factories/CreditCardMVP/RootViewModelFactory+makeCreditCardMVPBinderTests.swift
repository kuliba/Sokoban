//
//  RootViewModelFactory+makeCreditCardMVPBinderTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.03.2025.
//

import Combine
import CreditCardMVPCore
import CreditCardMVPUI
import FlowCore
import RxViewModel
import StateMachines

/// A namespace.
typealias CreditCardMVPDomain = GenericCreditCardMVPDomain<Content>

typealias ContentDomain = CreditCardMVPContentDomain
typealias Content = RxViewModel<ContentDomain.State, ContentDomain.Event, ContentDomain.Effect>

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
        
        case approved(consent: AttributedString, ProductCard)
        case draft(Draft)
        case inReview
        case rejected(ProductCard)
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
}

extension CreditCardMVPContentDomain {
    
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
    func makeCreditCardMVPBinder() -> CreditCardMVPDomain.Binder {
        
        let load: ContentDomain.Load = { _ in }
        
        let apply: ContentDomain.Apply = { _ in }
        
        return makeCreditCardMVPBinder(load: load, apply: apply)
    }
    
    // TODO: add @inlinable
    func makeCreditCardMVPBinder(
        load: @escaping ContentDomain.Load,
        apply: @escaping ContentDomain.Apply
    ) -> CreditCardMVPDomain.Binder {
        
        let content = makeCreditCardMVPContent(load: load, apply: apply)
        content.event(.load(.load))
        
        return makeCreditCardMVPBinder(
            content: content,
            emitting: { $0.$state },
            dismissing: { content in { content.event(.dismissInformer) }}
        )
    }
    
    // TODO: add @inlinable
    func makeCreditCardMVPContent(
        load: @escaping ContentDomain.Load,
        apply: @escaping ContentDomain.Apply
    ) -> Content {
        
        let draftableReducer = ContentDomain.DraftableReducer()
        let finalReducer = ContentDomain.FinalReducer()
        
        return .init(
            initialState: .pending,
            reduce: { state, event in // TODO: extract reducer
                
                var state = state
                var effect: ContentDomain.Effect?
                
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
    func makeCreditCardMVPBinder<Content>(
        content: Content,
        emitting: @escaping (Content) -> some Publisher<CreditCardMVPContentDomain.State, Never>,
        dismissing: @escaping ContentWitnesses<Content, FlowEvent<CreditCardMVPFlowDomain.Select, Never>>.Dismissing
    ) -> Binder<Content, CreditCardMVPFlowDomain.Flow> {
        
        return composeBinder(
            content: content,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { emitting($0).compactMap(\.selectEvent) },
                dismissing: dismissing
            )
        )
    }
}

private extension String {
    
#warning("to use in load and appy mapping")
    static let alertMessage = "Попробуйте позже."
    static let informerLoadMessage = "Ошибка загрузки данных.\nПопробуйте позже."
    static let informerApplyMessage = "Ошибка отправки заявки.\nПопробуйте повторить."
}

extension ContentDomain.State {
    
    var selectEvent: FlowEvent<CreditCardMVPFlowDomain.Select, Never>? {
        
        select.map { .select($0) }
    }
    
    var select: CreditCardMVPFlowDomain.Select? {
        
        switch self {
        case let .completed(.approved(consent, product)):
            return .approved(consent: consent, product)
            
        case let .completed(.draft(draft)):
            switch draft.application {
            case let .completed(.approved(consent, product)):
                return .approved(consent: consent, product)
                
            case .completed(.inReview):
                return .inReview
                
            case .completed(.rejected):
                return .rejected
                
            case let .failure(failure):
                switch failure.type {
                case .alert:    return .failure
                case .informer: return .informer(failure.message)
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
            case .alert:    return .alert(failure.message)
            case .informer: return .informer(failure.message)
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

final class RootViewModelFactory_makeCreditCardMVPBinderTests: CreditCardMVPRootViewModelFactory {
    
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
        
        let message = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: alert(message))
        
        XCTAssertTrue(sut.flow.isShowingAlert(with: message))
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onInformerFailure() {
        
        let message = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: informer(message))
        
        XCTAssertTrue(sut.flow.isShowingInformer(with: message))
    }
    
    func test_shouldRemoveInformer_onDismiss() {
        
        let message = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        loadSpy.complete(with: informer(message))
        XCTAssertTrue(sut.flow.isShowingInformer(with: message))
        
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
        
        assertFailure(sut.flow, message: failureMessage)
    }
    
    func test_shouldShowInformer_onDraftApplyInformerFailure() {
        
        let message = anyMessage()
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: informer(message))
        
        XCTAssertTrue(sut.flow.isShowingInformer(with: message))
    }
    
    func test_shouldRemoveInformer_onDismiss_onDraftApply() {
        
        let message = anyMessage()
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        sut.content.event(.apply(.load))
        applySpy.complete(with: informer(message))
        XCTAssertTrue(sut.flow.isShowingInformer(with: message)) // flow.isShowingInformer or what is showing??
        
        sut.flow.event(.dismiss)
        
        XCTAssertFalse(sut.content.hasConnectivityError)
    }
    
    func test_shouldNavigateToApproved_onApprovedApplyStatus() {
        
        let (consent, product) = (makeConsent(), makeProductCard())
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: approved(consent: consent, product: product))
        
        assertApproved(
            sut.flow,
            consent: consent,
            product: product,
            message: approvedMessage,
            title: approvedTitle,
            info: approvedInfo
        )
    }
    
    func test_shouldNavigateToRejected_onInReviewApplyStatus() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: .inReview)
        
        assertInReview(sut.flow, message: inReview)
    }
    
    func test_shouldNavigateToRejected_onRejectedApplyStatus() {
        
        let (sut, loadSpy, applySpy) = makeSUT()
        loadSpy.complete(with: draft())
        
        sut.content.event(.apply(.load))
        applySpy.complete(with: rejected())
        
        assertRejected(
            sut.flow,
            message: rejectedMessage,
            title: rejectedTitle
        )
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let (consent, product) = (makeConsent(), makeProductCard())
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: approved(consent: consent, product: product))
        
        assertApproved(
            sut.flow,
            consent: consent,
            product: product,
            message: approvedMessage,
            title: approvedTitle,
            info: approvedInfo
        )
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: .inReview)
        
        assertInReview(sut.flow, message: inReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        loadSpy.complete(with: rejected())
        
        assertRejected(
            sut.flow,
            message: rejectedMessage,
            title: rejectedTitle
        )
    }
    
    // MARK: - loading
    
    func test_shouldNotNavigate_onLoadingStatus() {
        
        let (sut, _,_) = makeSUT()
        
        sut.content.event(.load(.load))
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - pending
    
    func test_shouldNotNavigate_onPendingStatus() {
        
        let (sut, _,_) = makeSUT()
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = CreditCardMVPDomain
    
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
        let sut = factory.makeCreditCardMVPBinder(
            load: loadSpy.process,
            apply: applySpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(applySpy, file: file, line: line)
        
        return (sut, loadSpy, applySpy)
    }
}

final class RootViewModelFactory_makeCreditCardMVPBinderGenericContentTests: CreditCardMVPRootViewModelFactory {
    
    func test_shouldNotCallDismissInitially() {
        
        let (sut, _, dismissing) = makeSUT()
        
        XCTAssertEqual(dismissing.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldHaveNoNavigationInitially() {
        
        let (sut, _,_) = makeSUT()
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - alert
    
    func test_shouldShowAlert_onAlertFailure() {
        
        let message = anyMessage()
        let (sut, subject, _) = makeSUT()
        
        send(subject, alert(message))
        
        XCTAssertTrue(sut.flow.isShowingAlert(with: message))
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onInformerFailure() {
        
        let message = anyMessage()
        let (sut, subject, _) = makeSUT()
        
        send(subject, informer(message))
        
        XCTAssertTrue(sut.flow.isShowingInformer(with: message))
    }
    
    func test_shouldRemoveInformer_onDismiss_onInformerFailure() {
        
        let (sut, subject, dismissing) = makeSUT()
        subject.send(.failure(informer()))
        
        sut.flow.event(.dismiss)
        
        XCTAssertEqual(dismissing.callCount, 1)
    }
    
    // MARK: - draft (form)
    
    func test_shouldNotNavigate_onDraftStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft())
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNavigateToFailure_onDraftApplicationAlertFailure() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft(application: .failure(alert())))
        
        assertFailure(sut.flow, message: failureMessage)
    }
    
    func test_shouldNavigateToFailure_onDraftApplicationInformerFailure() {
        
        let message = anyMessage()
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft(application: .failure(informer(message))))
        
        XCTAssertTrue(sut.flow.isShowingInformer(with: message))
    }
    
    func test_shouldRemoveInformer_onDismiss_onDraftApplicationInformerFailure() {
        
        let message = anyMessage()
        let (sut, subject, dismissing) = makeSUT()
        subject.send(.completed(draft(application: .failure(informer(message)))))
        XCTAssertTrue(sut.flow.isShowingInformer(with: message)) // flow.isShowingInformer or what is showing??
        
        sut.flow.event(.dismiss)
        
        XCTAssertEqual(dismissing.callCount, 1)
    }
    
    func test_shouldNavigateToApproved_onDraftApprovedApplicationStatus() {
        
        let (consent, product) = (makeConsent(), makeProductCard())
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft(application: .completed(approved(consent: consent, product: product))))
        
        assertApproved(
            sut.flow,
            consent: consent,
            product: product,
            message: approvedMessage,
            title: approvedTitle,
            info: approvedInfo
        )
    }
    
    func test_shouldNavigateToRejected_onDraftInReviewApplicationStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft(application: .completed(.inReview)))
        
        assertInReview(sut.flow, message: inReview)
    }
    
    func test_shouldNavigateToRejected_onDraftRejectedApplicationStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft(application: .completed(rejected())))
        
        assertRejected(
            sut.flow,
            message: rejectedMessage,
            title: rejectedTitle
        )
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let (consent, product) = (makeConsent(), makeProductCard())
        let (sut, subject, _) = makeSUT()
        
        send(subject, approved(consent: consent, product: product))
        
        assertApproved(
            sut.flow,
            consent: consent,
            product: product,
            message: approvedMessage,
            title: approvedTitle,
            info: approvedInfo
        )
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, .inReview)
        
        assertInReview(sut.flow, message: inReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, rejected())
        
        assertRejected(
            sut.flow,
            message: rejectedMessage,
            title: rejectedTitle
        )
    }
    
    // MARK: - loading
    
    func test_shouldNotNavigate_onLoadingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        subject.send(.loading(.none))
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNotNavigate_onDraftLoadingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        send(subject, draft())
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNotNavigate_onApprovedLoadingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        subject.send(.loading(approved()))
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNotNavigate_onInReviewLoadingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        subject.send(.loading(.inReview))
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    func test_shouldNotNavigate_onRejectedLoadingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        subject.send(.loading(rejected()))
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - pending
    
    func test_shouldNotNavigate_onPendingStatus() {
        
        let (sut, subject, _) = makeSUT()
        
        subject.send(.pending)
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Binder<Subject, Domain.Flow>
    private typealias Subject = PassthroughSubject<CreditCardMVPContentDomain.State, Never>
    private typealias Domain = CreditCardMVPDomain
    private typealias DismissingSpy = CallSpy<Void, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        subject: Subject,
        dismissing: DismissingSpy
    ) {
        let subject = Subject()
        let dismissing = DismissingSpy(stubs: [()])
        let (factory, _,_) = super.makeSUT(file: file, line: line)
        let sut = factory.makeCreditCardMVPBinder(
            content: subject,
            emitting: { $0 },
            dismissing: { _ in dismissing.call }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, subject, dismissing)
    }
    
    private func send(
        _ subject: Subject,
        _ status: CreditCardMVPContentDomain.DraftableStatus
    ) {
        subject.send(.completed(status))
    }
    
    private func send(
        _ subject: Subject,
        _ failure: LoadFailure<ContentDomain.FailureType>
    ) {
        subject.send(.failure(failure))
    }
}

class CreditCardMVPRootViewModelFactory: RootViewModelFactoryTests {
    
    let approvedInfo = "Про то что можно забрать в офисе"
    let approvedMessage = "Ваша кредитная карта готова к оформлению!"
    let approvedTitle = "Кредитная карта одобрена"
    
    let failureMessage = "Что-то пошло не так...\nПопробуйте позже."
    
    let inReview = "Ожидайте рассмотрения Вашей заявки\nРезультат придет в Push/смс\nПримерное время рассмотрения заявки 10 минут."
    
    let rejectedMessage = "К сожалению, ваша кредитная история не позволяет оформить карту"
    let rejectedTitle = "Кредитная карта не одобрена"
    
    typealias ContentDomain = CreditCardMVPContentDomain
    
    func alert(
        _ message: String = anyMessage()
    ) -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: message, type: .alert)
    }
    
    func informer(
        _ message: String = anyMessage()
    ) -> LoadFailure<ContentDomain.FailureType> {
        
        return .init(message: message, type: .informer)
    }
    
    func approved(
        consent: AttributedString? = nil,
        product: ProductCard? = nil
    ) -> ContentDomain.FinalStatus {
        
        return .approved(
            consent: consent ?? makeConsent(),
            product ?? makeProductCard()
        )
    }
    
    func approved(
        consent: AttributedString? = nil,
        product: ProductCard? = nil
    ) -> ContentDomain.DraftableStatus {
        
        return .approved(
            consent: consent ?? makeConsent(),
            product ?? makeProductCard()
        )
    }
    
    func rejected(
        _ product: ProductCard? = nil
    ) -> ContentDomain.FinalStatus {
        
        return .rejected(product ?? makeProductCard())
    }
    
    func rejected(
        _ product: ProductCard? = nil
    ) -> ContentDomain.DraftableStatus {
        
        return .rejected(product ?? makeProductCard())
    }
    
    func draft(
        application: ContentDomain.Draft.ApplicationState = .pending
    ) -> ContentDomain.DraftableStatus {
        
        return .draft(.init(application: application))
    }
    
    func makeConsent(
        _ value: String = anyMessage()
    ) -> AttributedString {
        
        return .init(value)
    }
    
    func makeProductCard(
        limit: String = anyMessage(),
        md5Hash: String = anyMessage(),
        options: [ProductCard.Option] = [
            .init(title: anyMessage(), value: anyMessage())
        ],
        title: String = anyMessage(),
        subtitle: String = anyMessage()
    ) -> ProductCard {
        
        return .init(
            limit: limit,
            md5Hash: md5Hash,
            options: options,
            title: title,
            subtitle: subtitle
        )
    }
    
    func assertApproved(
        _ flow: CreditCardMVPDomain.Flow,
        consent: AttributedString,
        product: ProductCard,
        message: String,
        title: String,
        info: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .decision(decision):
            XCTAssertNoDiff(decision, .init(message: message, status: .approved(.init(consent: consent, info: info, product: product)), title: title), file: file, line: line)
            
        default:
            XCTFail("Expected decision case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertFailure(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .complete(complete):
            XCTAssertNoDiff(complete, .init(message: message, status: .failure), file: file, line: line)
            
        default:
            XCTFail("Expected complete case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertInReview(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .complete(complete):
            XCTAssertNoDiff(complete, .init(message: message, status: .inReview), file: file, line: line)
            
        default:
            XCTFail("Expected complete case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
    
    func assertRejected(
        _ flow: CreditCardMVPDomain.Flow,
        message: String,
        title: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flow.state.navigation {
        case let .decision(decision):
            XCTAssertNoDiff(decision, .init(message: message, status: .rejected, title: title), file: file, line: line)
            
        default:
            XCTFail("Expected decision case, but got \(String(describing: flow.state.navigation)) instead.", file: file, line: line)
        }
    }
}

// MARK: - DSL

extension Content {
    
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
    
    func isShowingAlert(
        with message: String = anyMessage()
    ) -> Bool {
        
        guard case let .alert(alert) = state.navigation else { return false }
        return alert == message
    }
    
    func isShowingInformer(
        with message: String = anyMessage()
    ) -> Bool {
        
        guard case let .informer(informer) = state.navigation else { return false }
        return informer == message
    }
}
