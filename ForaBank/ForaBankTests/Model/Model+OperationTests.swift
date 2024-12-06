//
//  Model+OperationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

import Combine
import XCTest
@testable import ForaBank

final class Model_OperationTests: XCTestCase {
    
    func test_shouldNotSendDetailResponseActionOnSuccessfulOperationDetailRequesResponse() {
        
        let sut = makeSUT(detail: .emptyDataDetail)
        let spy = ValueSpy(sut.emptyDataMessagePublisher)
        XCTAssertNoDiff(spy.values, [])
        
        sut.sendDetailRequestAndWait()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_shouldSendDetailWithEmptyDataResponse_shouldSetupIsLoadingFalse() {
        
        let sut = makeSUT(detail: .emptyDataDetail)
        let operationDetail = OperationDetailViewModel(
            productStatement: .stub(),
            product: .stub(), 
            updateFastAll: {},
            model: sut
        )
        
        XCTAssertNoDiff(operationDetail.isLoading, true)
        
        sut.sendDetailRequestAndWait()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.8)
        
        XCTAssertNoDiff(operationDetail.isLoading, false)
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

private extension Model {
   
    typealias Publisher = Publishers.MapKeyPath<Publishers.CompactMap<PassthroughSubject<any Action, Never>, ModelAction.Operation.Detail.Response>, String?>
    
    var emptyDataMessagePublisher: Publisher {

      action
        .compactMap { $0 as? ModelAction.Operation.Detail.Response }
        .map(\.emptyDataMessage)
    }
    
    func sendDetailRequestAndWait(timeout: TimeInterval = 0.05) {
        
        let request = ModelAction.Operation.Detail.Request.documentId(123)
        action.send(request)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
