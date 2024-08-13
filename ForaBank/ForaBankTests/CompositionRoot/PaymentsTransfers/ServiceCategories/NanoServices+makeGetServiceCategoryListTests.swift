//
//  NanoServices+makeGetServiceCategoryListTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.08.2024.
//

@testable import ForaBank
import XCTest

// TODO: improve tests
final class NanoServices_makeGetServiceCategoryListTests: XCTestCase {
    
    func test_shouldCallHTTPClient() {
        
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for HTTPClient")
        
        sut { _ in exp.fulfill() }
        httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.GetServiceCategoryList
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeGetServiceCategoryList(httpClient, { _,_,_ in })
        
        return (sut, httpClient)
    }
}
