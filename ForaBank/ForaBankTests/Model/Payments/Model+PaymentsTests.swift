//
//  Model+PaymentsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.06.2023.
//

@testable import ForaBank
import ServerAgent
import XCTest

final class Model_PaymentsTests: XCTestCase {
    
    // MARK: - isSingleService
    
    func test_isSingleService_shouldThrowOnServerError() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.failure())]
        )
        
        try await assertThrows(
            try await sut.isSingleService("any")
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.isSingleService.serverCommandError(error: "Server: data corrupted: Server: unexpected empty response data") as NSError
            )
        }
    }
    
    func test_isSingleService_shouldThrowOnServerErrorNotAuthorized() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.failure(.notAuthorized))]
        )
        
        try await assertThrows(
            try await sut.isSingleService("any")
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.isSingleService.serverCommandError(error: "Server: data corrupted: Server: unexpected empty response data") as NSError
            )
        }
    }
    
    func test_isSingleService_shouldThrowOnUserNotAuthorized() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.success(statusCode: .userNotAuthorized))]
        )
        
        try await assertThrows(
            try await sut.isSingleService("any")
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.isSingleService.statusError(status: .userNotAuthorized, message: nil) as NSError
            )
        }
    }
    
    func test_isSingleService_shouldThrowOnNilData() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.success(data: nil))]
        )
        
        try await assertThrows(try await sut.isSingleService("any")) {
            
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.isSingleService.emptyData(message: nil) as NSError)
        }
    }
    
    func test_isSingleService_shouldReturnTrue_onSuccessfulResponseWithTrue() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.success(data: true))]
        )
        
        let isSingleService = try await sut.isSingleService("any")
        
        XCTAssertTrue(isSingleService)
    }
    
    func test_isSingleService_shouldReturnTrue_onSuccessfulResponseWithFalse() async throws {
        
        let sut = makeSUT(
            serverStub: [.isSingleService(.success(data: false))]
        )
        
        let isSingleService = try await sut.isSingleService("any")
        
        XCTAssertFalse(isSingleService)
    }

    // MARK: - Step
    func test_step_withTransferData_shouldReturnNextStepOperation() async throws {
        
        let sut = makeSUT()
        
        let step = try await sut.step(
            for: .makeDummy(),
            with: .makeTransferAnywayResponseData(
                finalStep: false,
                needSum: false,
                scenario: .suspect
            )
        )
        
        XCTAssertTrue(step.parametersIds.contains(where: { $0 == "AFResponse" }))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        serverStub: [ServerAgentTestStub.Stub] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: ActiveSessionAgentStub(),
            serverAgent: ServerAgentTestStub(serverStub)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

extension ServerAgentTestStub.Stub.IsSingleServiceResponseResult {
    
    static func success(
        statusCode: ServerStatusCode = .ok,
        errorMessage: String? = nil,
        data: Bool? = nil
    ) -> Self {
        
        .success(.init(statusCode: statusCode, errorMessage: errorMessage, data: data))
    }
    
    static func failure(
        serverAgentError: ServerAgentError = .emptyResponseData
    ) -> Self {
        
        .failure(serverAgentError)
    }
}
