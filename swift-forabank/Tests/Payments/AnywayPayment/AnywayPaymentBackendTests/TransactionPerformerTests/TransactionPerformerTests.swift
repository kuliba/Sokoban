//
//  TransactionPerformerTests.swift
//
//
//  Created by Igor Malyarov on 24.03.2024.
//

import AnywayPaymentBackend
import XCTest

final class TransactionPerformerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, makeTransfer, getDetails) = makeSUT()
        
        XCTAssertEqual(makeTransfer.callCount, 0)
        XCTAssertEqual(getDetails.callCount, 0)
    }
    
    func test_process_shouldCallMakeTransferWithCode() {
        
        let code = Code()
        let (sut, makeTransfer, _) = makeSUT()
        
        sut.process(code) { _ in }
        
        XCTAssertNoDiff(makeTransfer.payloads, [code])
    }
    
    func test_process_shouldDeliverMakeTransferErrorFailureOnMakeTransferFailure() {
        
        let (sut, makeTransfer, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init()), on: {
            
            makeTransfer.complete(with: .failure(.init()))
        })
    }
    
    func test_process_shouldCallGetDetailsWithDetailsID() {
        
        let code = Code()
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        sut.process(code) { _ in }
        makeTransfer.complete(with: .success(payload))
        
        XCTAssertNoDiff(getDetails.payloads, [detailsID])
    }
    
    func test_process_shouldDeliverMakeTransferResponseOnGetDetailsFailure() {
        
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(makeTransferResponse: payload, details: nil)), on: {
            
            makeTransfer.complete(with: .success(payload))
            getDetails.complete(with: .failure(anyError()))
        })
    }
    
    func test_process_shouldDeliverMakeTransferResponseWithDetailsOnGetDetailsSuccess() {
        
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let details = Details()
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(makeTransferResponse: payload, details: details)), on: {
            
            makeTransfer.complete(with: .success(payload))
            getDetails.complete(with: .success(details))
        })
    }
    
    func test_process_shouldNotDeliverMakeTransferFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        (sut, makeTransfer, _) = makeSUT()
        var response: SUT.ProcessResult?
        
        sut?.process(.init()) { response = $0 }
        sut = nil
        makeTransfer.complete(with: .failure(.init()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(response)
    }
    
    func test_process_shouldNotDeliverGetDetailsResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        let getDetails: GetDetailsSpy
        (sut, makeTransfer, getDetails) = makeSUT()
        var response: SUT.ProcessResult?
        
        sut?.process(.init()) { response = $0 }
        makeTransfer.complete(with: .success(.init(detailsID: .init())))
        sut = nil
        getDetails.complete(with: .failure(anyError()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(response)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransactionPerformer<Code, Details, Payload>
    private typealias MakeTransferSpy = Spy<Code, SUT.MakeTransferResult>
    private typealias GetDetailsSpy = Spy<DetailsID, SUT.GetDetailsResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeTransfer: MakeTransferSpy,
        getDetails: GetDetailsSpy
    ) {
        let makeTransfer = MakeTransferSpy()
        let getDetails = GetDetailsSpy()
        let sut = SUT(
            makeTransfer: makeTransfer.process,
            getDetails: getDetails.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeTransfer, file: file, line: line)
        trackForMemoryLeaks(getDetails, file: file, line: line)
        
        return (sut, makeTransfer, getDetails)
    }
    
    private func expect(
        _ sut: SUT,
        with code: Code = .init(),
        toDeliver expected: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(code) {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

private struct Code: Equatable {
    
    let value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

private struct Details: Equatable {
    
    let value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

private struct DetailsID: Equatable {
    
    let value: String
    
    init(value: String = UUID().uuidString) {
        
        self.value = value
    }
}

private struct Payload: Detailable, Equatable {
    
    let detailsID: DetailsID
}
