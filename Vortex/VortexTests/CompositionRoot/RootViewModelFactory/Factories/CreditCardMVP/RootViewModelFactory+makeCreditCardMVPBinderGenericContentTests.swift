//
//  RootViewModelFactory+makeCreditCardMVPBinderGenericContentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.03.2025.
//

@testable import Vortex
import Combine
import CreditCardMVPCore
import XCTest

final class RootViewModelFactory_makeCreditCardMVPBinderGenericContentTests: CreditCardMVPRootViewModelFactoryTests {
    
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
            isDelayed: false,
            emitting: { $0.compactMap(\.select) },
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
