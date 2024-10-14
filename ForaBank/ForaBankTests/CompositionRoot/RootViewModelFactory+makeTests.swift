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
        
        let (_, httpClient, _, backgroundScheduler, bindings) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        backgroundScheduler.advance()
        
        XCTAssertNoDiff(httpClient.callCount, 0)
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldCallHTTPClientOnActiveSessionState() {
        
        let (_, httpClient, _, backgroundScheduler, bindings) = makeSUT(
            sessionState: active()
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        backgroundScheduler.advance()
        
        XCTAssertGreaterThan(httpClient.callCount, 0)
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldCallHTTPClientOnSessionStateChangeToActive() {
        
        let (_, httpClient, sessionAgent, backgroundScheduler, bindings) = makeSUT(
            sessionState: .inactive
        )
        XCTAssertEqual(httpClient.callCount, 0)
        
        sessionAgent.sessionState.value = active()
        backgroundScheduler.advance()
        
        XCTAssertGreaterThanOrEqual(httpClient.callCount, 1)
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListOnActiveSession() throws {
        
        let request = try createGetServiceCategoryListRequest(serial: nil)
        let (_, httpClient, _, backgroundScheduler, bindings) = makeSUT(
            sessionState: active()
        )
        
        backgroundScheduler.advance()
        
        XCTAssert(httpClient.requests.contains(request))
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldSetCategoryPickerStateToLoading() throws {
        
        let (sut, _,_,_,_) = makeSUT()
        
        let initialState = try sut.categoryPickerContent().state
        
        XCTAssertNoDiff(initialState.isLoading, true)
    }
    
    func test_shouldNotChangeCategoryPickerStateOnMissingHTTPCompletion() throws {
        
        let (sut, _,_, backgroundScheduler, bindings) = makeSUT(
            sessionState: active()
        )
        let initialState = try sut.categoryPickerContent().state
        
        backgroundScheduler.advance()
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state, initialState)
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPCompletion() throws {
        
        let (sut, httpClient, _, backgroundScheduler, bindings) = makeSUT(
            sessionState: active()
        )
        
        backgroundScheduler.advance()
        httpClient.complete(with: success())
        backgroundScheduler.advance(to: .init(.now() + .seconds(8)))
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNotNil(bindings)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewModel
    
    private func makeSUT(
        sessionState: SessionState = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        sessionAgent: SessionAgentEmptyMock,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>,
        bindings: Set<AnyCancellable>
    ) {
        let httpClient = HTTPClientSpy()
        let backgroundScheduler = DispatchQueue.test
        var bindings = Set<AnyCancellable>()
        let sessionAgent = SessionAgentEmptyMock()
        sessionAgent.sessionState.value = sessionState
        let model: Model = .mockWithEmptyExcept(sessionAgent: sessionAgent)
        let sut = RootViewModelFactory.make(
            model: model,
            httpClient: httpClient,
            logger: LoggerSpy(),
            bindings: &bindings,
            qrResolverFeatureFlag: .init(.active),
            fastPaymentsSettingsFlag: .init(.active(.live)),
            utilitiesPaymentsFlag: .init(.active(.live)),
            historyFilterFlag: .init(true),
            changeSVCardLimitsFlag: .init(.active),
            getProductListByTypeV6Flag: .init(.active),
            marketplaceFlag: .init(.inactive),
            paymentsTransfersFlag: .init(.active),
            updateInfoStatusFlag: .init(.active),
            mainScheduler: .immediate,
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        
        return (sut, httpClient, sessionAgent, backgroundScheduler, bindings)
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
        
        guard case let .v1(switcher) = tabsViewModel.paymentsModel,
              case let .personal(personal) = switcher.state
        else { return nil }
        
        return personal
    }
}
