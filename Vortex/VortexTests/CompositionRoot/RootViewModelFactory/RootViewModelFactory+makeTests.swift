//
//  RootViewModelFactory+makeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.08.2024.
//

import Combine
import CombineSchedulers
@testable import Vortex
import PayHub
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
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListOnActiveSessionAgain() throws {
        
        let (sut, httpClient, sessionAgent, userInitiatedScheduler) = makeSUT()
        sessionAgent.activate()
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        userInitiatedScheduler.advance()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])

        sessionAgent.deactivate()
        sessionAgent.activate()
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
            "getServiceCategoryList",
        ])
        
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
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: anyError(), at: 2)
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
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: mobileJSON(), at: 2)
        awaitActorThreadHop()
        
        let state = try sut.content.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNoDiff(state.elements.map(\.type), ["mobile"])
    }
    
    func test_shouldRequestOperatorsAfterCategories() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: getServiceCategoryListJSON(), at: 2)
        awaitActorThreadHop()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getOperatorsListByParam-housingAndCommunalService",
            "getServiceCategoryList",
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCacheLoadedServiceCategoriesOnSuccess() throws {
        
        let localAgent = LocalAgentMock(values: [])
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            localAgent: localAgent,
            sessionState: active()
        )
        XCTAssertNil(localAgent.lastStoredValue(ofType: [CodableServiceCategory].self))
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: getServiceCategoryListJSON(), at: 2)
        awaitActorThreadHop()
        
        XCTAssertEqual(localAgent.getStoredValues(ofType: [CodableServiceCategory].self).count, 1, "Expected to cache ServiceCategories once.")
        XCTAssertNoDiff(localAgent.lastStoredValue(ofType: [CodableServiceCategory].self)?.map(\.type), [
            "mobile",
            "housingAndCommunalService",
            "internet",
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallHTTPClient() throws {
        
        let localAgent = LocalAgentMock(values: [])
        let (_, httpClient, _,_) = makeSUT(
            localAgent: localAgent,
            sessionState: active(),
            schedulers: .immediate
        )
        
        awaitActorThreadHop()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
    }
    
    func test_shouldCacheLoadedOperatorsOnSuccess() throws {
        
        let localAgent = LocalAgentMock(values: [])
        let (_, httpClient, _,_) = makeSUT(
            localAgent: localAgent,
            sessionState: active(),
            schedulers: .immediate
        )
        
        awaitActorThreadHop()
        XCTAssert(localAgent.getStoredValues(ofType: [CodableServicePaymentOperator].self).isEmpty)
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getServiceCategoryList",
        ])
        
        try httpClient.complete(with: anyError(), for: authRequest())
        try httpClient.complete(with: getServiceCategoryListJSON(), for: categoriesRequest())
        try httpClient.complete(with: anyError(), for: bannersRequest())
        
        awaitActorThreadHop()
        
        // getOperatorsListByParam-housingAndCommunalService
        httpClient.complete(with: getOperatorsListByParamJSON(), at: 3)
        awaitActorThreadHop()
        
        // getOperatorsListByParam-internet
        httpClient.complete(with: anyError(), at: 4)
        awaitActorThreadHop()
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getOperatorsListByParam-housingAndCommunalService",
            "getOperatorsListByParam-internet",
            "getServiceCategoryList",
        ])
        
        XCTAssertEqual(localAgent.getStoredValues(ofType: [CodableServicePaymentOperator].self).count, 1, "Expected to cache Operators once.")
        XCTAssertNoDiff(localAgent.lastStoredValue(ofType: [CodableServicePaymentOperator].self)?.map(\.name), [
            "ООО МЕТАЛЛЭНЕРГОФИНАНС",
            "ООО  ИЛЬИНСКОЕ ЖКХ",
            "ТОВАРИЩЕСТВО СОБСТВЕННИКОВ НЕДВИЖИМОСТИ ЧИСТОПОЛЬСКАЯ 61 А",
        ])
    }
    
    func test_shouldRequestNextTypeOperators() throws {
        
        let (sut, httpClient, _, userInitiatedScheduler) = makeSUT(
            sessionState: active()
        )
        
        userInitiatedScheduler.advance()
        awaitActorThreadHop()
        
        httpClient.complete(with: anyError())
        
        httpClient.complete(with: getServiceCategoryListJSON(), at: 2)
        awaitActorThreadHop()
        
        httpClient.complete(with: anyError(), at: 3)
        userInitiatedScheduler.advance(to: .init(.now().advanced(by: RootViewModelFactorySettings.prod.batchDelay.timeInterval)))
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: "type").map { $0 ?? "nil" }.sorted(), [
            "getBannerCatalogList",
            "getNotAuthorizedZoneClientInformData",
            "getOperatorsListByParam-housingAndCommunalService",
            "getOperatorsListByParam-internet",
            "getServiceCategoryList",
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Vortex.RootViewDomain.Binder
    
    private func makeSUT(
        localAgent: LocalAgentProtocol? = nil,
        sessionState: SessionState = .inactive,
        mapScanResult: @escaping RootViewModelFactory.MapScanResult = { _, completion in completion(.unknown) },
        schedulers: Schedulers? = nil,
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
            schedulers: schedulers ?? .test(
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
        
        try Vortex.RequestFactory.createGetServiceCategoryListRequest(serial: serial)
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
    
    private func authRequest() -> URLRequest {
        
        RequestFactory.createGetNotAuthorizedZoneClientInformDataRequest()
    }
    
    private func bannersRequest(
        serial: String? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBannerCatalogListV2Request(serial)
    }
    
    private func categoriesRequest(
        serial: String? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetServiceCategoryListRequest(serial: serial)
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
    ) throws -> Vortex.PaymentsTransfersPersonalDomain.Binder {
        
        try XCTUnwrap(personal, "Expected to have v1", file: file, line: line)
    }
    
    private var personal: Vortex.PaymentsTransfersPersonalDomain.Binder? {
        
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
