//
//  ComposedCVVPINServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class ComposedCVVPINServiceTests: XCTestCase {
    
    // MARK: - activate
    
    func test_activate_shouldDeliverServiceErrorOnActivateInvalidFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.invalid(statusCode: 500, data: anyData()))
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverServiceErrorOnActivateNetworkFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.network)
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverServerErrorOnActivateServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let sut = makeSUT(
            activateResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectActivate(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_activate_shouldDeliverServiceErrorOnActivateServiceFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.serviceFailure)
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverPhoneOnActivateSuccess() {
        
        let phone = "+7..7856"
        let sut = makeSUT(
            activateResult: anySuccess(phone)
        )
        
        expectActivate(sut, toDeliver: .success(.init(phone)))
    }
    
    // MARK: - confirmWith
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            confirmActivationResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmNetworkFailure() {
        
        let sut = makeSUT(
            confirmActivationResult: .failure(.network)
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverRetryErrorOnConfirmRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure. Retry"
        let retryAttempts = 5
        let sut = makeSUT(
            confirmActivationResult: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
    }
    
    func test_confirmWith_shouldDeliverServerErrorOnConfirmServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure. Retry"
        let sut = makeSUT(
            confirmActivationResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmServiceFailure() {
        
        let sut = makeSUT(
            confirmActivationResult: .failure(.serviceFailure)
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverVoidOnConfirmSuccess() {
        
        let sut = makeSUT(
            confirmActivationResult: .success(())
        )
        
        expectConfirmWith(sut, toDeliver: .success(()))
    }
    
    // MARK: - checkFunctionality
    
    func test_checkFunctionality_shouldDeliverActivationErrorOnCheckActivationFailure() {
        
        let sut = makeSUT(
            checkActivationResult: .failure(anyNSError())
        )
        
        expectCheckFunctionality(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_expectCheckFunctionality_shouldDeliverVoidOnActivateSuccess() {
        
        let sut = makeSUT(
            checkActivationResult: .success(())
        )
        
        expectCheckFunctionality(sut, toDeliver: .success(()))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    
    private func makeSUT(
        activateResult: CVVPINActivateResult = anySuccess(),
        changePINResult: ChangePINResult = anySuccess(),
        checkActivationResult: Result<Void, Error> = .success(()),
        confirmActivationResult: CVVPINConfirmResult = .success(()),
        getPINConfirmationCodeResult: GetPINConfirmationCodeResult = anySuccess(),
        showCVVResult: ShowCVVService.Result = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            activate: { $0(activateResult) },
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: { $0(checkActivationResult) },
            confirmActivation: { _, completion  in completion(confirmActivationResult) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            showCVV: { _, completion in completion(showCVVResult) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expectActivate(
        _ sut: SUT,
        toDeliver expectedResult: ActivateCVVPINClient.ActivateResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.activate(completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case let (
                .success(expected),
                .success(received)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectConfirmWith(
        _ sut: SUT,
        toDeliver expectedResult: ActivateCVVPINClient.ConfirmationResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.confirmWith(otp: UUID().uuidString, completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectCheckFunctionality(
        _ sut: SUT,
        toDeliver expectedResult: ChangePINClient.CheckFunctionalityResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.checkFunctionality(completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
}
