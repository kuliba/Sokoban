//
//  GetProcessingSessionCodeServiceTests.swift
//  
//
//  Created by Igor Malyarov on 19.10.2023.
//

import CVVPINServices
import XCTest

final class GetProcessingSessionCodeServiceTests: XCTestCase {
    
    func test_init_shouldNotCallProcess() {
        
        let (_, service) = makeSUT()
        
        XCTAssertNoDiff(service.callCount, 0)
    }
    
    func test_getCode_shouldDeliverFailureOnProcessFailure() {
        
        let processError = APIError.server(statusCode: 1234, errorMessage: "Process Failure")
        let (sut, service) = makeSUT()
        
        getCodeResults(sut, delivers: .failure(processError), on: {
            
            service.complete(with: .failure(processError))
        })
    }
    
    func test_getCode_shouldDeliverSuccessOnProcessSuccess() {
        
        let success = anySuccess()
        let (sut, service) = makeSUT()
        
        getCodeResults(sut, delivers: success, on: {
            
            service.complete(with: success)
        })
    }
    
    func test_getCode_shouldNotDeliverResultOnSUTInstanceDeallocation() {
        
        var sut: SUT?
        let service: Service
        (sut, service) = makeSUT()
        var receivedResults = [Result]()
        
        sut?.getCode {
            
            receivedResults.append($0)
        }
        sut = nil
        service.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias APIError = ResponseMapper.GetCodeMapperError
    private typealias SUT = GetProcessingSessionCodeService<APIError>
    private typealias Service = RemoteServiceSpy<GetProcessingSessionCodeResponse, APIError, Void>
    private typealias Result = SUT.Result
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        service: Service
    ) {
        let service = Service()
        let sut = SUT(process: service.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        
        return (sut, service)
    }
    
    private func getCodeResults(
        _ sut: SUT,
        delivers expectedResult: Result,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.getCode {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(receivedResults, equalsTo: [expectedResult])
    }
}

private func anySuccess(
    code: String = UUID().uuidString,
    phone: String = UUID().uuidString
) -> Result<GetProcessingSessionCodeResponse, ResponseMapper.GetCodeMapperError> {
    
    .success(
        .init(
            code: .init(code: code),
            phone: .init(phone: phone)
        )
    )
}
