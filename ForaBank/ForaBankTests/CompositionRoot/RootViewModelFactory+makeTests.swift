//
//  RootViewModelFactory+makeTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.08.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeTests: XCTestCase {
    
    func test_shouldCallHTTPClient() {
        
        let (_, httpClient, backgroundScheduler) = makeSUT()
        XCTAssertNoDiff(httpClient.callCount, 0)
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        XCTAssertNoDiff(httpClient.callCount, 1)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryList() throws {
        
        let (_, httpClient, backgroundScheduler) = makeSUT()
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        XCTAssertNoDiff(httpClient.requests, [
            try ForaBank.RequestFactory.createGetServiceCategoryListRequest()
        ])
    }
    
    func test_shouldSetCategoryPickerStateToLoading() throws {
        
        let (sut, _,_) = makeSUT()
        
        let initialState = try sut.categoryPickerContent().state
        
        XCTAssertNoDiff(initialState.isLoading, true)
    }
    
    func test_shouldNotChangeCategoryPickerStateOnNoHTTPCompletion() throws {
        
        let (sut, _, backgroundScheduler) = makeSUT()
        let initialState = try sut.categoryPickerContent().state
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state, initialState)
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPCompletion() throws {
        
        let (sut, httpClient, backgroundScheduler) = makeSUT()
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        httpClient.complete(with: success())
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewModel
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let httpClient = HTTPClientSpy()
        let backgroundScheduler = DispatchQueue.test
        let sut = RootViewModelFactory.make(
            model: .mockWithEmptyExcept(),
            httpClient: httpClient,
            logger: LoggerSpy(),
            qrResolverFeatureFlag: .init(.active),
            fastPaymentsSettingsFlag: .init(.active(.live)),
            utilitiesPaymentsFlag: .init(.active(.live)),
            historyFilterFlag: .init(true),
            changeSVCardLimitsFlag: .init(.active),
            getProductListByTypeV6Flag: .init(.active),
            paymentsTransfersFlag: .init(.active),
            updateInfoStatusFlag: .init(.active),
            mainScheduler: .immediate,
            backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
        )
        
        return (sut, httpClient, backgroundScheduler)
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
}

// MARK: - DSL

private extension RootViewModel {
    
    func categoryPickerContent(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> CategoryPickerSectionContent {
        
        let v1 = try paymentsModelV1(file: file, line: line)
        
        return v1.content.categoryPicker.content
    }
    
    func paymentsModelV1(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsTransfersPersonal {
        
        try XCTUnwrap(binder, "Expected to have v1", file: file, line: line)
    }
    
    private var binder: PaymentsTransfersPersonal? {
        
        guard case let .v1(binder) = paymentsModel else { return nil }
        return binder
    }
}
