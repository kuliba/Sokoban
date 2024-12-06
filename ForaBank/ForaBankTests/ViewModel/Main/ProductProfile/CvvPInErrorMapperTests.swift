//
//  CvvPInErrorMapperTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 13.10.2023.
//

import XCTest
@testable import ForaBank

final class CvvPInErrorMapperTests: XCTestCase {

    // MARK: - test ChangePINError
   func test_map_changePinError_server_statusCodeNot7051_shouldErrorScreen() {

       let error = CVVPinErrorMapper.map(ChangePINError.server(statusCode: 4, errorMessage: "error"))

       XCTAssertNoDiff(error, .pinError(.errorScreen))
    }
    
    func test_map_changePinError_server_statusCode7051_shouldError() {

        let error = CVVPinErrorMapper.map(ChangePINError.server(statusCode: 7051, errorMessage: "error"))

        XCTAssertNoDiff(error.message?.rawValue, "error")
    }

    func test_map_changePinError_retry_retryAttempts0_shouldTechnicalError() {
        
        let error = CVVPinErrorMapper.map(ChangePINError.retry(statusCode: 4, errorMessage: "error", retryAttempts: 0))
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
    
    func test_map_changePinError_retry_retryAttemptsMore0_shouldIncorrectCode() {

        let error = CVVPinErrorMapper.map(ChangePINError.retry(statusCode: 4, errorMessage: "error", retryAttempts: 1))

        XCTAssertNoDiff(error.message?.rawValue, String.incorrectСode)
    }

    func test_map_changePinError_retryAttemptsNil_statusCode7051_shouldSimpleCode() {

        let error = CVVPinErrorMapper.map(ChangePINError.weakPIN(statusCode: 1, errorMessage: "error"))

        XCTAssertNoDiff(error.message?.rawValue, String.simpleCode)
    }

    func test_map_changePinError_serviceFailure_shouldTechnicalError() {
        
        let error = CVVPinErrorMapper.map(ChangePINError.serviceFailure)
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
    
    // MARK: - test GetPINConfirmationCodeError
    func test_map_otpError_retryAttempts0_shouldeReturnTechnicalError() {
        
        let error = CVVPinErrorMapper.map(ConfirmationCodeError.retry(statusCode: 0, errorMessage: "error", retryAttempts: 0))
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
    
    func test_map_otpError_retryAttemptsMore0_shouldReturnIncorrectCode() {
       
        let error = CVVPinErrorMapper.map(ConfirmationCodeError.retry(statusCode: 0, errorMessage: "error", retryAttempts: 1))
        
        XCTAssertNoDiff(error.message?.rawValue, String.incorrectСode)
    }
    
    func test_map_otpError_serviceFailure_shouldReturnTechnicalError() {
        
        let error = CVVPinErrorMapper.map(ConfirmationCodeError.serviceFailure)
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
    
    func test_map_otpError_server_shouldReturnTechnicalError() {
        
        let error = CVVPinErrorMapper.map(ConfirmationCodeError.server(statusCode: 45, errorMessage: "error"))
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
}
