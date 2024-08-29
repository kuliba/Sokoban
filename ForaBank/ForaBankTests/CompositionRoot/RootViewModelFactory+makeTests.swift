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
}
