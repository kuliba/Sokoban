//
//  NanoServices+initiateAnywayPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 12.08.2024.
//

@testable import ForaBank
import XCTest

final class NanoServices_initiateAnywayPaymentTests: XCTestCase {
    
    func test_live_shouldCallHTTPClient() {
        
        let puref = anyMessage()
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(puref) { _ in exp.fulfill() }
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        spy.complete(with: .empty)
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(spy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.MakeInitiateAnywayPayment
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.initiateAnywayPayment(
            httpClient: httpClient,
            log: { _,_,_,_,_ in },
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, httpClient)
    }
}
