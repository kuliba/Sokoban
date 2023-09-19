//
//  Model+OperationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

@testable import ForaBank
import XCTest

final class Model_OperationTests: XCTestCase {
    
    func test_shouldNotSendDetailResponseActionOnSuccessfulOperationDetailRequesResponse() {
        
        let sut = makeSUT(detail: .emptyDataDetail)
        let spy = ValueSpy(
            sut.action
                .compactMap { $0 as? ModelAction.Operation.Detail.Response }
                .map(\.emptyDataMessage)
        )
        XCTAssertNoDiff(spy.values, [])
        
        let request = ModelAction.Operation.Detail.Request(type: .documentId(123))
        sut.action.send(request)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values, [])
    }
    
    // MARK: - Helpers
    
    private typealias GetOperationDetailResponse = ServerCommands.PaymentOperationDetailContoller.GetOperationDetail.Response

    private func makeSUT(
        detail: GetOperationDetailResponse,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let stub: [ServerAgentTestStub.Stub] = [
            .getOperationDetail(.success(detail))
        ]
        let serverAgent = ServerAgentTestStub(stub)
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: ActiveSessionAgentStub(),
            serverAgent: serverAgent
        )

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension ModelAction.Operation.Detail.Response {
    
    var emptyDataMessage: String? {
        
        switch result {
        case let .failure(.emptyData(message: message)):
            return message
            
        default:
            return nil
        }
    }
}

private extension ServerCommands.PaymentOperationDetailContoller.GetOperationDetail.Response {
    
    static let emptyDataDetail: Self = .init(
        statusCode: .ok,
        errorMessage: "empty data",
        data: nil
    )
}
