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
}
