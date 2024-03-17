//
//  GetProductListByTypeService+getProductListByTypeService.swift
//  ForaBankTests
//
//  Created by Disman Dmitry on 15.03.2024.
//

@testable import ForaBank
import GetProductListByTypeService
import GenericRemoteService
import XCTest

final class Services_getProductListByTypeServiceTests: XCTestCase {
    
    func test_getProductListByTypeData_statusOkEmptyData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mapResponse(Self.defaultDataRequest))) {
            spy.complete(with: .success(Self.makeSuccessResponse(with: .emptyData)))
        }
    }
    
    func test_getProductListByTypeData_statusOkErrorData_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mapResponse(Self.errorDataRequest))) {
            spy.complete(with: .success(Self.makeSuccessResponse(with: .errorData)))
        }
    }

    func test_getProductListByTypeData_statusNotOk_shouldDeliverError() throws {
        
        let (sut, spy) = makeSUT()
        
        try expect(sut, toDeliver: .failure(.mapResponse(Self.serverErrorDataRequest))) {
            spy.complete(with: .success(Self.makeSuccessResponse(with: .serverError, statusCode: 999)))
        }
    }
        
    func test_getProductListByTypeData_statusOk_shouldDeliverEmpty() throws {
        
        let (sut, spy) = makeSUT()
                
        try expect(sut, toDeliver: .success(Self.emptyProductList)) {
            spy.complete(with: .success(Self.makeSuccessResponse(with: .emptySuccessData)))
        }
    }
    
    // MARK: - Helpers
    
    private typealias Payload = Services.GetProductListByTypePayload
    private typealias Result = Swift.Result<ProductListData, RemoteServiceError<any Error, any Error, MappingError>>
    private typealias ReceivedError = RemoteServiceError<any Error, any Error, MappingError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Services.GetProductListByTypeRemoteService,
        spy: HTTPClientSpy
    ) {
        let spy = HTTPClientSpy()
        let sessionAgent = ActiveInactiveSessionAgent()
        sessionAgent.activate()
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent
        )
        
        let authenticatedHTTPClient = model.authenticatedHTTPClient(
            httpClient: spy
        )
        
        let sut = Services.makeGetProductListByTypeService(httpClient: authenticatedHTTPClient)

        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sessionAgent, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
                
        return (sut, spy)
    }
    
    private static func makeSuccessResponse(
        with string: String,
        statusCode: Int = 200
    ) -> (Data, HTTPURLResponse) {
        
        (data(with: string), anyHTTPURLResponse(with: statusCode))
    }
    
    private static func data(with string: String) -> Data {
        
        string.data(using: .utf8)!
    }
    
    private static func error(statusCode: Int, dataString: String) -> MappingError {
        
        .invalid(statusCode: statusCode, data: data(with: dataString))
    }
    
    private static let defaultDataRequest: MappingError = error(statusCode: 200, dataString: .emptyData)
    private static let errorDataRequest: MappingError = error(statusCode: 200, dataString: .errorData)
    private static let serverErrorDataRequest: MappingError = error(statusCode: 999, dataString: .serverError)
    private static let emptyProductList: ProductListData = .init(serial: "", productList: [])
    
    private func expect(
        _ sut: Services.GetProductListByTypeRemoteService,
        toDeliver expectedResult: Result,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let exp = expectation(description: "wait for completion")
        let payload: Payload = .card
        
        sut.process(payload) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (receivedError, expectedError):
                
                switch (receivedError, expectedError) {
                case let (.failure(.mapResponse(receivedMappingError)), .failure(.mapResponse(expectedMappingError))):
                                        
                    XCTAssertNoDiff(
                        receivedMappingError,
                        expectedMappingError,
                        "Expected \(expectedError), got \(receivedError) instead.",
                        file: file, line: line
                    )
                case let (.success(receivedProductListData), .success(expectedProductListData)):
                    
                    XCTAssertNoDiff(
                        receivedProductListData,
                        expectedProductListData,
                        "Expected \(expectedError), got \(receivedError) instead.",
                        file: file, line: line
                    )
                    
                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
                }
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension String {
    
    static let defaultErrorMessage: Self = "Возникла техническая ошибка"
    
    static let serverError: Self = "server error"
    
    static let emptyData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": null
    }
"""
    static let errorData: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {}
    }
"""
    static let emptySuccessData: Self = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "",
    "productList": [
    ]
  }
}
"""
}

