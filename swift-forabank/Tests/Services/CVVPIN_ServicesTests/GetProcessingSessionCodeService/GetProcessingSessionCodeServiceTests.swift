//
//  GetProcessingSessionCodeServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class GetProcessingSessionCodeServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, processSpy) = makeSUT()
        
        XCTAssertNoDiff(processSpy.callCount, 0)
    }
    
    func test_getCode_shouldDeliverErrorOnGetCodeInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            processSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_getCode_shouldDeliverErrorOnGetCodeNetworkFailure() {
        
        let (sut, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            processSpy.complete(with: .failure(.network))
        })
    }
    
    func test_getCode_shouldDeliverErrorOnGetCodeServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process error"
        let (sut, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            processSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_getCode_shouldDeliverSuccessOnSuccess() {
        
        let code = UUID().uuidString
        let phone = "+7..6789"
        let (sut, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .success(.init(code: code, phone: phone))
        ], on: {
            processSpy.complete(with: .success(.init(code: code, phone: phone)))
        })
    }
    
    func test_getCode_shouldNotDeliverProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processSpy: ProcessSpy
        (sut, processSpy) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.getCode { receivedResults.append($0) }
        sut = nil
        processSpy.complete(with: .failure(.network))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetProcessingSessionCodeService
    private typealias ProcessSpy = Spy<Void, SUT.Response, SUT.APIError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        processSpy: ProcessSpy
    ) {
        let processSpy = ProcessSpy()
        let sut = SUT(process: processSpy.process(completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        
        return (sut, processSpy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.Result],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.getCode {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
}

private extension Array where Element == GetProcessingSessionCodeService.Result {
    
    func mapToEquatable() -> [GetProcessingSessionCodeService.Result.Result] {
        
        map { $0.mapToEquatable() }
    }
}

private extension GetProcessingSessionCodeService.Result {
    
    func mapToEquatable() -> Result {
        
        self
            .map(EquatableSuccess.init)
            .mapError(EquatableError.init)
    }
    
    typealias Result = Swift.Result<EquatableSuccess, EquatableError>
    
    struct EquatableSuccess: Equatable {
        
        let code: String
        let phone: String
        
        init(success: GetProcessingSessionCodeService.Response) {
            
            self.code = success.code
            self.phone = success.phone
        }
    }
    
    enum EquatableError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        
        init(error: GetProcessingSessionCodeService.Error) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
            }
        }
    }
}
