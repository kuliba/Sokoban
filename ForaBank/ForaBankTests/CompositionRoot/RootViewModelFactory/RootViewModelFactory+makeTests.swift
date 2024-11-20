//
//  RootViewModelFactory+makeTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.08.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeTests: XCTestCase {
    
    func test_shouldNotCallHTTPClientOnInactiveSessionState() {
        
        let (sut, httpClient, _, backgroundScheduler) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        backgroundScheduler.advance()
        awaitActorThreadHop()
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientOnActiveSessionState() {
        
        let (sut, httpClient, _, backgroundScheduler) = makeSUT(
            sessionState: active()
        )
        
        backgroundScheduler.advance()
        awaitActorThreadHop()
        backgroundScheduler.advance()
        
        XCTAssertGreaterThan(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientOnSessionStateChangeToActive() {
        
        let (sut, httpClient, sessionAgent, backgroundScheduler) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        sessionAgent.sessionState.value = active()
        backgroundScheduler.advance()
        awaitActorThreadHop()
        
        XCTAssertGreaterThanOrEqual(httpClient.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListOnActiveSession() throws {
        
        let request = try createGetServiceCategoryListRequest(serial: nil)
        let (sut, httpClient, _, backgroundScheduler) = makeSUT(
            sessionState: active()
        )
        
        backgroundScheduler.advance()
        awaitActorThreadHop()
        backgroundScheduler.advance()
        
        XCTAssert(httpClient.requests.contains(request))
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetCategoryPickerStateToLoading() throws {
        
        let (sut, _,_,_) = makeSUT()
        
        let initialState = try sut.content.categoryPickerContent().state
        
        XCTAssertNoDiff(initialState.isLoading, true)
    }
    
    func test_shouldNotChangeCategoryPickerStateOnMissingHTTPCompletion() throws {
        
        let (sut, _,_, backgroundScheduler) = makeSUT(
            sessionState: active()
        )
        let initialState = try sut.content.categoryPickerContent().state
        
        backgroundScheduler.advance()
        awaitActorThreadHop()
        backgroundScheduler.advance()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state, initialState)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPCompletionWithNewSerial() throws {
        
        let (sut, httpClient, _, backgroundScheduler) = makeSUT(
            sessionState: active()
        )
        
        backgroundScheduler.advance()
        
        httpClient.complete(with: success())
        awaitActorThreadHop()
        backgroundScheduler.advance()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewDomain.Binder
    
    private func makeSUT(
        sessionState: SessionState = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        sessionAgent: SessionAgentEmptyMock,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let httpClient = HTTPClientSpy()
        let backgroundScheduler = DispatchQueue.test
        let sessionAgent = SessionAgentEmptyMock()
        sessionAgent.sessionState.value = sessionState
        let model: Model = .mockWithEmptyExcept(sessionAgent: sessionAgent)
        let sut = RootViewModelFactory(
            model: model,
            httpClient: httpClient,
            logger: LoggerSpy(),
            resolveQR: { _ in .unknown },
            schedulers: .test(
                main: .immediate,
                background: backgroundScheduler.eraseToAnyScheduler()
            ).0
        ).make(
            dismiss: {},
            collateralLoanLandingFlag: .active,
            paymentsTransfersFlag: .active,
            savingsAccountFlag: .active
        )
        
        return (sut, httpClient, sessionAgent, backgroundScheduler)
    }
    
    private func createGetServiceCategoryListRequest(
        serial: String?
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetServiceCategoryListRequest(serial: serial)
    }
    
    private func success(
    ) -> Result<(Data, HTTPURLResponse), any Error> {
        
        return .success((validData(), anyHTTPURLResponse()))
    }
    
    private func validData(
    ) -> Data {
        
        return .init(validJSON().utf8)
    }
    
    private func validJSON(
    ) -> String {
        
        return """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "abc",
        "categoryGroupList": [
            {
                "type": "mobile",
                "name": "Мобильная связь",
                "ord": 20,
                "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
                "paymentFlow": "MOBILE",
                "latestPaymentsCategory": "isMobilePayments",
                "search": false
            }
        ]
    }
}
"""
    }
    
    private func active() -> SessionState {
        
        return .active(
            start: .infinity,
            credentials: .init(
                token: anyMessage(),
                csrfAgent: CSRFAgentDummy.dummy
            )
        )
    }
}

// MARK: - DSL

private extension RootViewModel {
    
    func categoryPickerContent(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> CategoryPickerSectionDomain.ContentDomain.Content {
        
        let v1 = try personal(file: file, line: line)
        
        return v1.content.categoryPicker.content
    }
    
    func personal(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsTransfersPersonal {
        
        try XCTUnwrap(personal, "Expected to have v1", file: file, line: line)
    }
    
    private var personal: PaymentsTransfersPersonal? {
        
        guard case let .v1(switcher as PaymentsTransfersSwitcher) = tabsViewModel.paymentsModel,
              case let .personal(personal) = switcher.state
        else { return nil }
        
        return personal
    }
}
