//
//  TransactionPerformerTests.swift
//
//
//  Created by Igor Malyarov on 24.03.2024.
//

import AnywayPaymentCore
import XCTest

final class TransactionPerformerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, makeTransfer, getDetails) = makeSUT()
        
        XCTAssertEqual(makeTransfer.callCount, 0)
        XCTAssertEqual(getDetails.callCount, 0)
    }
    
    func test_process_shouldCallMakeTransferWithCode() {
        
        let code = makeVerificationCode()
        let (sut, makeTransfer, _) = makeSUT()
        
        sut.process(code) { _ in }
        
        XCTAssertNoDiff(makeTransfer.payloads, [code])
    }
    
    func test_process_shouldDeliverMakeTransferErrorFailureOnMakeTransferFailure() {
        
        let (sut, makeTransfer, _) = makeSUT()
        
        expect(sut, toDeliver: nil, on: {
            
            makeTransfer.complete(with: nil)
        })
    }
    
    func test_process_shouldCallGetDetailsWithDetailsID() {
        
        let code = makeVerificationCode()
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        sut.process(code) { _ in }
        makeTransfer.complete(with: payload)
        
        XCTAssertNoDiff(getDetails.payloads, [detailsID])
    }
    
    func test_process_shouldDeliverMakeTransferResponseOnGetDetailsFailure() {
        
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        expect(sut, toDeliver: .init(makeTransferResponse: payload, details: nil), on: {
            
            makeTransfer.complete(with: payload)
            getDetails.complete(with: nil)
        })
    }
    
    func test_process_shouldDeliverMakeTransferResponseWithDetailsOnGetDetailsSuccess() {
        
        let detailsID = DetailsID()
        let payload = Payload(detailsID: detailsID)
        let details = Details()
        let (sut, makeTransfer, getDetails) = makeSUT()
        
        expect(sut, toDeliver: .init(makeTransferResponse: payload, details: details), on: {
            
            makeTransfer.complete(with: payload)
            getDetails.complete(with: details)
        })
    }
    
    func test_process_shouldNotDeliverMakeTransferFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        (sut, makeTransfer, _) = makeSUT()
        var responses = [SUT.ProcessResult]()
        
        sut?.process(makeVerificationCode()) { responses.append($0) }
        sut = nil
        makeTransfer.complete(with: nil)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssert(responses.isEmpty)
    }
    
    func test_process_shouldNotDeliverGetDetailsResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        let getDetails: GetDetailsSpy
        (sut, makeTransfer, getDetails) = makeSUT()
        var responses = [SUT.ProcessResult]()
        
        sut?.process(makeVerificationCode()) { responses.append($0) }
        makeTransfer.complete(with: .init(detailsID: .init()))
        sut = nil
        getDetails.complete(with: nil)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssert(responses.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransactionPerformer<Details, Payload>
    private typealias MakeTransferSpy = Spy<VerificationCode, SUT.MakeTransferResult>
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
            getDetails: getDetails.process,
            makeTransfer: makeTransfer.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeTransfer, file: file, line: line)
        trackForMemoryLeaks(getDetails, file: file, line: line)
        
        return (sut, makeTransfer, getDetails)
    }
    
    private func expect(
        _ sut: SUT,
        with code: VerificationCode = makeVerificationCode(),
        toDeliver expected: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(code) {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(String(describing: expected)), but got \(String(describing: $0)) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
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
