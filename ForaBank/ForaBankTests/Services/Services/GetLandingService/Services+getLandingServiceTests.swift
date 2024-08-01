//
//  Services+getLandingServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2023.
//

import CodableLanding
@testable import ForaBank
import GenericRemoteService
import LandingUIComponent
import XCTest

final class Services_getLandingServiceTests: XCTestCase {
    
    private typealias RemoteError = RemoteServiceError<Error, Error, Error>
    
    func test_orderCard() {
        
        let abroadType: AbroadType = .orderCard
        let (sut, spy) = makeSUT()
        
        var results = [Result<UILanding, RemoteError>]()
        let exp = expectation(description: "wait for completion")
        
        sut.process((serial: "111", abroadType: abroadType)) { result in
            
            results.append(result)
            exp.fulfill()
        }
        spy.complete(with: .success(success()))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(results.count, 1)
    }
    
    func test_perform_abroadTransfer_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .transfer
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=abroadTransfer"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    func test_perform_abroadOrderCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .orderCard
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=abroadOrderCard"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    func test_perform_mainCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .control(.main)
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=CONTROL_MAIN_CARD"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    func test_perform_regularCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .control(.regular)
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=CONTROL_REGULAR_CARD"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }

    func test_perform_additionalSelfCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .control(.additionalSelf)
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=CONTROL_ADDITIONAL_SELF_CARD"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    func test_perform_additionalSelfAccOwnCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .control(.additionalSelfAccOwn)
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=CONTROL_ADDITIONAL_SELF_ACC_OWN_CARD"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }
    
    func test_perform_additionalOtherCard_shouldCallHTTPClientWithCorrectURLInRequest() {
        
        let abroadType: AbroadType = .control(.additionalOther)
        let (sut, spy) = makeSUT()
        let correctURLString = "https://pl.forabank.ru/dbo/api/v3/dict/v2/getJsonAbroad?serial=1&type=CONTROL_ADDITIONAL_OTHER_CARD"
        
        sut.process((serial: "1", abroadType: abroadType)) { _ in }
        
        XCTAssertNoDiff(
            spy.requests,
            [.init(url: .init(string: correctURLString)!)]
        )
    }

    // MARK: - Helpers
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Services.GetLandingService,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        
        let cache: Services.Cache = { _ in }

        let sut = Services.getLandingService(
            httpClient: spy,
            withCache: cache
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func success() -> (Data, HTTPURLResponse) {
        
        (.init(), anyHTTPURLResponse())
    }
}
