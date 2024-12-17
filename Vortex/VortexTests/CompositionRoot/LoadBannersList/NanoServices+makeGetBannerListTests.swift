//
//  NanoServices+makeGetBannerListTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 10.09.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest
import GetBannerCatalogListAPI

final class NanoServices_makeGetBannerListTests: XCTestCase {

    func test_shouldCallHTTPClient() {
        
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for HTTPClient")
        
        sut(defaultPayload) { _ in exp.fulfill() }
        httpClient.complete(with: .success((anyData(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_shouldCallHTTPClientWithGetServiceCategoryListRequest() throws {
        
        let (sut, httpClient) = makeSUT()
        let request = try createRequest()
        
        sut(defaultPayload) { _ in }
        
        XCTAssertNoDiff(httpClient.requests, [request])
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyData() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.empty, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnInvalidData() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.invalidData, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyJSON, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyDataResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.nullServerResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverServerErrorOnServerError() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError("Возникла техническая ошибка"))) {
            
            httpClient.complete(with: .success((.serverError, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(with: statusCode)
            let (sut, httpClient) = makeSUT()
            
            expect(sut, toDeliver: .failure(.connectivityError)) {
                
                httpClient.complete(with: .success((.valid, nonOkResponse)))
            }
        }
    }
    
    func test_shouldDeliverInvalidFailureOnEmptyList() {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError)) {
            
            httpClient.complete(with: .success((.emptyDataResponse, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverResponseWithOne() throws {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .success(.one)) {
            
            httpClient.complete(with: .success((.one, anyHTTPURLResponse())))
        }
    }
    
    func test_shouldDeliverResponse() throws {
        
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toDeliver: .success(.valid)) {
            
            httpClient.complete(with: .success((.valid, anyHTTPURLResponse())))
        }
    }
    
    // MARK: - Helpers
    
    let defaultPayload: (String?, TimeInterval) = ("", 0)
    
    private typealias SUT = NanoServices.GetBannersList
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeGetBannersList(
            httpClient: httpClient,
            log: { _,_,_ in }
        )
        
        return (sut, httpClient)
    }
    
    private func createRequest(
        _ serial: String? = ""
    ) throws -> URLRequest {
        
        try RequestFactory.createGetBannerCatalogListV2Request(serial)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: NanoServices.GetBannersListResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut(defaultPayload) {
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}

private extension GetBannerCatalogListResponse {
    
    static let one: Self = .init(
        serial: "1",
        bannerCatalogList: [
            .init(
                productName: "productName",
                conditions: ["condition"],
                links: .init(
                    image: "imageLink",
                    order: "orderLink",
                    condition: "conditionLink"),
                action: nil)
        ]
    )
    
    static let valid: Self = .init(
        serial: "2",
        bannerCatalogList: [
            .init(
                productName: "productName",
                conditions: ["condition"],
                links: .init(
                    image: "imageLink",
                    order: "orderLink",
                    condition: "conditionLink"),
                action: nil),
            .init(
                productName: "productName1",
                conditions: ["condition1"],
                links: .init(
                    image: "imageLink1",
                    order: "orderLink1",
                    condition: "conditionLink1"),
                action: .init(type: .depositsList))
        ]
    )
}

private extension Data {
    
    static let invalidData: Data = String.invalidData.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let one: Data = String.one.json
    static let valid: Data = String.valid.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "BannerCatalogList": []
  }
}
"""
    
    static let one = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1",
    "BannerCatalogList": [
      {
        "productName": "productName",
        "txtСondition": [
          "condition"
        ],
        "imageLink": "imageLink",
        "orderLink": "orderLink",
        "conditionLink": "conditionLink",
        "action": null
      }
    ]
  }
}
"""
    
    static let valid = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "2",
    "BannerCatalogList": [
      {
        "productName": "productName",
        "txtСondition": [
          "condition"
        ],
        "imageLink": "imageLink",
        "orderLink": "orderLink",
        "conditionLink": "conditionLink",
        "action": null
      },
      {
        "productName": "productName1",
        "txtСondition": [
          "condition1"
        ],
        "imageLink": "imageLink1",
        "orderLink": "orderLink1",
        "conditionLink": "conditionLink1",
            "action": {
              "type": "DEPOSITS"
            }
      },
    ]
  }
}
"""
}
