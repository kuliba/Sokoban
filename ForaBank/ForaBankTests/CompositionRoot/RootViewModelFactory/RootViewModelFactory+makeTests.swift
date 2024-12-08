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

final class RootViewModelFactory_makeTests: RootViewModelFactoryServiceCategoryTests {
    
    func test_shouldNotCallHTTPClientOnInactiveSessionState() {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        userInitiatedScheduler.advance()
        
        XCTAssertNoDiff(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientOnActiveSessionState() {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        userInitiatedScheduler.advance()
        
        XCTAssertGreaterThan(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientOnSessionStateChangeToActive() {
        
        let (sut, httpClient, sessionAgent, userInitiatedScheduler) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        sessionAgent.sessionState.value = active()
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        XCTAssertGreaterThanOrEqual(httpClient.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListOnActiveSession() throws {
        
        let request = try createGetServiceCategoryListRequest(serial: nil)
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        userInitiatedScheduler.advance()
        
        XCTAssert(httpClient.requests.contains(request))
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetCategoryPickerStateToLoading() throws {
        
        let (sut, _,_,_) = makeSUT()
        
        let initialState = try sut.content.categoryPickerContent().state
        
        XCTAssertNoDiff(initialState.isLoading, true)
    }
    
    func test_shouldNotChangeCategoryPickerStateOnMissingHTTPCompletion() throws {
        
        let (sut, _,_, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        let initialState = try sut.content.categoryPickerContent().state
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        userInitiatedScheduler.advance()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state, initialState)
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPFailure() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        httpClient.expectRequests(withQueryValueFor: "type", match: [
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: anyError(), at: 1)
        awaitActorThreadHop()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNoDiff(state.elements, [])
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPCompletionWithNewSerial() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        httpClient.expectRequests(withQueryValueFor: "type", match: [
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: mobileJSON(), at: 1)
        awaitActorThreadHop()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNoDiff(state.elements.map(\.type), [.mobile])
    }
    
    func test_shouldRequestOperatorsAfterCategories() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        httpClient.expectRequests(withQueryValueFor: "type", match: [
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: getServiceCategoryListJSON(), at: 1)
        awaitActorThreadHop()
        
        httpClient.expectRequests(withQueryValueFor: "type", match: [
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
            "getOperatorsListByParam-housingAndCommunalService"
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldRequestNextTypeOperators() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        httpClient.complete(with: anyError())

        httpClient.complete(with: getServiceCategoryListJSON(), at: 1)
        awaitActorThreadHop()
        
        httpClient.complete(with: anyError(), at: 2)
        awaitActorThreadHop()
        
        httpClient.expectRequests(withQueryValueFor: "type", match: [
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
            "getOperatorsListByParam-housingAndCommunalService",
            "getOperatorsListByParam-internet"
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewDomain.Binder
    
    private func makeSUT(
        localAgent: LocalAgentProtocol? = nil,
        sessionState: SessionState = .inactive,
        mapScanResult: @escaping RootViewModelFactory.MapScanResult = { _, completion in completion(.unknown) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        sessionAgent: SessionAgentEmptyMock,
        userInitiatedScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let localAgent = localAgent ?? LocalAgentEmptyMock()
        let sessionAgent = SessionAgentEmptyMock()
        sessionAgent.sessionState.value = sessionState
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            localAgent: localAgent
        )
        let httpClient = HTTPClientSpy()
        let userInitiatedScheduler = DispatchQueue.test
        let factory = RootViewModelFactory(
            model: model,
            httpClient: httpClient,
            logger: LoggerSpy(),
            mapScanResult: mapScanResult,
            resolveQR: { _ in .unknown },
            scanner: QRScannerViewModelSpy(),
            schedulers: .test(
                main: .immediate,
                userInitiated: userInitiatedScheduler.eraseToAnyScheduler()
            ).0
        )
        let sut = factory.make(
            dismiss: {},
            collateralLoanLandingFlag: .active,
            paymentsTransfersFlag: .active,
            savingsAccountFlag: .active
        )
        
        return (sut, httpClient, sessionAgent, userInitiatedScheduler)
    }
    
    private func createGetServiceCategoryListRequest(
        serial: String?
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createGetServiceCategoryListRequest(serial: serial)
    }
    
    private func mobileJSON() -> Data {
        
        return .init(String.mobileJSON.utf8)
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
        let binder = try XCTUnwrap(v1.content.categoryPicker.sectionBinder)
        
        return binder.content
    }
    
    func personal(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsTransfersPersonalDomain.Binder {
        
        try XCTUnwrap(personal, "Expected to have v1", file: file, line: line)
    }
    
    private var personal: PaymentsTransfersPersonalDomain.Binder? {
        
        guard case let .v1(switcher as PaymentsTransfersSwitcher) = tabsViewModel.paymentsModel,
              case let .personal(personal) = switcher.state
        else { return nil }
        
        return personal
    }
}

// MARK: - DSL

extension String {
    
    static let mobileJSON = """
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
