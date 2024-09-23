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
    
    func test_shouldCallHTTPClient() {
        
        let (_, httpClient, backgroundScheduler, _) = makeSUT()
        XCTAssertNoDiff(httpClient.callCount, 0)
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        XCTAssertNoDiff(httpClient.callCount, 2)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryList() throws {
        
        let (_, httpClient, backgroundScheduler, _) = makeSUT()
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        XCTAssertNoDiff(
            httpClient.requests.first,
            try ForaBank.RequestFactory.createGetServiceCategoryListRequest(serial: nil)
        )
    }
    
    func test_shouldSetCategoryPickerStateToLoading() throws {
        
        let (sut, _,_,_) = makeSUT()
        
        let initialState = try sut.categoryPickerContent().state
        
        XCTAssertNoDiff(initialState.isLoading, true)
    }
    
    func test_shouldNotChangeCategoryPickerStateOnMissingHTTPCompletion() throws {
        
        let (sut, _, backgroundScheduler, bindings) = makeSUT()
        let initialState = try sut.categoryPickerContent().state
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state, initialState)
        XCTAssertNotNil(bindings)
    }
    
    func test_shouldChangeCategoryPickerStateOnHTTPCompletion() throws {
        
        let (sut, httpClient, backgroundScheduler, bindings) = makeSUT()
        
        backgroundScheduler.advance(to: .init(.now() + .seconds(2)))
        httpClient.complete(with: success())
        
        let state = try sut.categoryPickerContent().state
        XCTAssertNoDiff(state.isLoading, false)
        XCTAssertNotNil(bindings)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewModel
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        backgroundScheduler: TestSchedulerOf<DispatchQueue>,
        bindings: Set<AnyCancellable>
    ) {
        let httpClient = HTTPClientSpy()
        let backgroundScheduler = DispatchQueue.test
        var bindings = Set<AnyCancellable>()
        let sut = RootViewModelFactory.make(
            model: .mockWithEmptyExcept(),
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
        
        return (sut, httpClient, backgroundScheduler, bindings)
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
        
        guard case let .v1(switcher) = tabsViewModelFactory.paymentsModel,
              case let .personal(personal) = switcher.state
        else { return nil }
        
        return personal
    }
}
