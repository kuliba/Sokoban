//
//  Services+getProcessingSessionCodeTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.08.2023.
//

@testable import ForaBank
import XCTest

final class Services_getProcessingSessionCodeTests: XCTestCase {
    
    func test_shouldNotCallHTTPClientUponCreation() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.requests.isEmpty)
    }
    
    func test_perform_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/processing/registration/v1/getProcessingSessionCode"
        
        sut.process { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
    ) -> (
        sut: Services.GetProcessingSessionCode,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        let sut = Services.getProcessingSessionCode(httpClient: spy)
        
        return (sut, spy)
    }
}
