//
//  InitiateAnywayPaymentMicroServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

@testable import ForaBank
import XCTest

final class InitiateAnywayPaymentMicroServiceTests: XCTestCase {
    
    func test_initiatePayment_shouldDeliverConnectivityErrorOnPaymentSourceParsingFailure() {
        
        let (sut, _) = makeSUT(paymentSourceParsingResult: nil)
        
        expect(sut, delivers: .failure(.connectivityError)) {}
    }
    
    func test_initiatePayment_shouldNotDeliverRemoteServiceResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let remote: ProcessPayloadSpy
        (sut, remote) = makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.isInverted = true
        
        sut?.initiatePayment(anySource()) { _ in exp.fulfill() }
        sut = nil
        remote.complete(with: .success(makeResponse()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_initiatePayment_shouldDeliverConnectivityErrorOnRemoteServiceConnectivityErrorFailure() {
        
        let (sut, remote) = makeSUT()
        
        expect(sut, delivers: .failure(.connectivityError)) {
            
            remote.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_initiatePayment_shouldDeliverServerErrorOnRemoteServiceServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, remote) = makeSUT()
        
        expect(sut, delivers: .failure(.serverError(message))) {
            
            remote.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_initiatePayment_shouldDeliverConnectivityErrorOnTransactionInitiationFailure() {
        
        let (sut, remote) = makeSUT(initiateTransactionResult: nil)
        
        expect(sut, delivers: .failure(.connectivityError)) {
            
            remote.complete(with: .success(makeResponse()))
        }
    }
    
    func test_initiatePayment_shouldDeliverCTransaction() {
        
        let transaction = makeTransaction()
        let (sut, remote) = makeSUT(initiateTransactionResult: transaction)
        
        expect(sut, delivers: .success(transaction)) {
            
            remote.complete(with: .success(makeResponse()))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = InitiateAnywayPaymentMicroService<InitiatePaymentSource, Payload, Response, Transaction>
    
    private typealias ServiceFailure = SUT.ServiceFailure
    private typealias ProcessPayloadSpy = Spy<Payload, Response, ServiceFailure>
    
    private typealias InitiatePaymentResult = SUT.InitiatePaymentResult
    
    private func makeSUT(
        paymentSourceParsingResult: Payload? = makePayload(),
        initiateTransactionResult: Transaction? = makeTransaction(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        remote: ProcessPayloadSpy
    ) {
        let remote = ProcessPayloadSpy()
        let sut = SUT(
            parseSource: { _ in paymentSourceParsingResult },
            processPayload: remote.process(_:completion:),
            initiateTransaction: { _,_ in initiateTransactionResult }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        
        return (sut, remote)
    }
    
    private func anySource() -> InitiatePaymentSource {
        
        makeInitiatePaymentSource()
    }
    
    private func expect(
        _ sut: SUT,
        with source: InitiatePaymentSource? = nil,
        delivers expectedResult: InitiatePaymentResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        let payload = source ?? makeInitiatePaymentSource()
        
        sut.initiatePayment(payload) {
            
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

private struct InitiatePaymentSource: Equatable {
    
    let value: String
}

private func makeInitiatePaymentSource(
    value: String = anyMessage()
) -> InitiatePaymentSource {
    
    return .init(value: value)
}

private struct Payload: Equatable {
    
    let value: String
}

private func makePayload(
    value: String = anyMessage()
) -> Payload {
    
    return .init(value: value)
}

private struct Response: Equatable {
    
    let value: String
}

private func makeResponse(
    value: String = anyMessage()
) -> Response {
    
    return .init(value: value)
}

private struct Transaction: Equatable {
    
    let value: String
}

private func makeTransaction(
    value: String = anyMessage()
) -> Transaction {
    
    return .init(value: value)
}
