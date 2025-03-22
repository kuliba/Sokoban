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
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - alert
    
    func test_shouldShowAlert_onServerError() {
        
        let sut = makeSUT()
        
        sut.content.send(.failure(.init(message: anyMessage(), type: .alert))) // httpClient.complete(with: makeServerErrorData())
        
        XCTAssertTrue(sut.flow.isShowingAlert)
    }
    
    // MARK: - informer
    
    func test_shouldShowInformer_onConnectivityError() {
        
        let sut = makeSUT()
        
        sut.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: anyError())
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldShowInformer_onUnknownStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: makeUnknownStatusData())
        
        XCTAssertTrue(sut.flow.isShowingInformer)
    }
    
    func test_shouldRemoveInformer_onDismiss() {
        
        let sut = makeSUT()
        sut.content.send(.failure(.init(message: anyMessage(), type: .informer))) // httpClient.complete(with: anyError())
        XCTAssertTrue(sut.flow.isShowingInformer)
        
        sut.flow.event(.dismiss)
        
        XCTAssertFalse(sut.content.hasConnectivityError)
    }
    
    // MARK: - form
    
    func test_shouldShowForm_onDraftStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.completed(.draft)) // httpClient.complete(with: makeDraftStatusData())
        
        XCTAssertTrue(sut.content.hasForm)
    }
    
    func test_shouldNotNavigate_onDraftStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.completed(.draft)) // httpClient.complete(with: makeDraftStatusData())
        
        XCTAssertNil(sut.flow.state.navigation)
    }
    
    // MARK: - approved
    
    func test_shouldNavigateToApproved_onApprovedStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.completed(.approved)) // httpClient.complete(with: makeApprovedStatusData())
        
        XCTAssertTrue(sut.flow.isShowingApproved)
    }
    
    // MARK: - inReview
    
    func test_shouldNavigateToRejected_onInReviewStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.completed(.inReview)) // httpClient.complete(with: makeInReviewStatusData())
        
        XCTAssertTrue(sut.flow.isShowingInReview)
    }
    
    // MARK: - rejected
    
    func test_shouldNavigateToRejected_onRejectedStatus() {
        
        let sut = makeSUT()
        
        sut.content.send(.completed(.rejected)) // httpClient.complete(with: makeRejectedStatusData())
        
        XCTAssertTrue(sut.flow.isShowingRejected)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CreditCardMVPDomain.Binder
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let (factory, _,_) = super.makeSUT(file: file, line: line)
        let sut = factory.makeCreditCardMVPBinder()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
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
