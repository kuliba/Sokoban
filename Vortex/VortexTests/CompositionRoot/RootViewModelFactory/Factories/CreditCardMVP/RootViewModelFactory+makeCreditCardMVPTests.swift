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
    
    typealias Content = CurrentValueSubject<State, Never> // RxViewModel<State, Event, Effect>
    typealias State = StateMachines.LoadState<ApplicationStatus, LoadFailure<Failure>>
    
    enum ApplicationStatus {
        
        case approved, draft, inReview, rejected
    }
    
    enum Failure {
        
        case alert, informer
    }
    
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

extension RootViewModelFactory {
    
    // TODO: add @inlinable
    func makeCreditCardMVPBinder() -> CreditCardMVPDomain.Binder {
        
        composeBinder(
            content: .init(.pending),
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { $0.compactMap(\.select) },
                dismissing: { content in { content.value = .pending }}
            )
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
    
    func test_shouldHaveNoNavigationInitially() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        XCTAssertNil(binder.flow.state.navigation)
    }
    
    // MARK: - alert
    
    func test_shouldShowAlert_onServerError() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.failure(.init(message: anyMessage(), type: .alert))) // httpClient.complete(with: makeServerErrorData())
        
        XCTAssertTrue(binder.flow.isShowingAlert)
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onConnectivityError() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: anyError())
        
        XCTAssertTrue(binder.flow.isShowingInformer)
    }
    
    func test_shouldShowInformer_onUnknownStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: makeUnknownStatusData())
        
        XCTAssertTrue(binder.flow.isShowingInformer)
    }
    
    func test_shouldRemoveInformer_onDismiss() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        binder.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: anyError())
        XCTAssertTrue(binder.flow.isShowingInformer)
        
        binder.flow.event(.dismiss)
        
        XCTAssertFalse(binder.content.hasConnectivityError)
    }
    
    // MARK: - form
    
    func test_shouldShowForm_onDraftStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.completed(.draft)) // httpClient.complete(with: makeDraftStatusData())
        
        XCTAssertTrue(binder.content.hasForm)
    }
    
    func test_shouldNotNavigate_onDraftStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.completed(.draft)) // httpClient.complete(with: makeDraftStatusData())
        
        XCTAssertNil(binder.flow.state.navigation)
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.completed(.approved)) // httpClient.complete(with: makeApprovedStatusData())
        
        XCTAssertTrue(binder.flow.isShowingApproved)
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.completed(.inReview)) // httpClient.complete(with: makeInReviewStatusData())
        
        XCTAssertTrue(binder.flow.isShowingInReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let (sut, _,_) = makeSUT()
        let binder = sut.makeCreditCardMVPBinder()
        
        binder.content.send(.completed(.rejected)) // httpClient.complete(with: makeRejectedStatusData())
        
        XCTAssertTrue(binder.flow.isShowingRejected)
    }
    
    // MARK: - Helpers
    
    func makeUnknownStatusData() -> Data { fatalError() }
    func makeDraftStatusData() -> Data { fatalError() }
    func makeApprovedStatusData() -> Data { fatalError() }
    func makeInReviewStatusData() -> Data { fatalError() }
    func makeRejectedStatusData() -> Data { fatalError() }
}

// MARK: - DSL

extension CreditCardMVPDomain.Content {
    
    var hasConnectivityError: Bool {
        
        guard case let .failure(failure) = value else { return false }
        return failure.type == .alert
    }
    
    var hasForm: Bool {
        
        guard case let .completed(status) = value else { return false }
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
