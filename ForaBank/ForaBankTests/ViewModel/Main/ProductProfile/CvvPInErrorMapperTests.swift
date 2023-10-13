//
//  CvvPInErrorMapperTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 13.10.2023.
//

import XCTest
@testable import ForaBank

final class CvvPInErrorMapperTests: XCTestCase {

    // MARK: - test ChangePinError
    func test_map_changePinError_retryAttemptsNil_statusCodeNot7051_shouldErrorScreen() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: nil, statusCode: 4))
        
        XCTAssertNoDiff(error, .errorScreen)
    }
    
    func test_map_changePinError_retryAttemptsMore0_statusCodeNot7051_shouldIncorrectCode() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: 1, statusCode: 4))
        
        XCTAssertNoDiff(error.message?.rawValue, String.incorrectСode)
    }
    
    func test_map_changePinError_retryAttemptsNil_statusCode7051_shouldSimpleCode() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: nil, statusCode: 7051))
        
        XCTAssertNoDiff(error.message?.rawValue, String.simpleCode)
    }
    
    func test_map_changePinError_retryAttempts0_statusCodeNot7051_shouldError() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: 0, statusCode: 111))
        
        XCTAssertNoDiff(error.message?.rawValue, "error")
    }
    
    // MARK: - test OtpError
    func test_map_otpError_retryAttempts0_shouldTechnicalError() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: 0))
        
        XCTAssertNoDiff(error.message?.rawValue, String.technicalError)
    }
    
    func test_map_otpError_retryAttemptsMore0_shouldIncorrectCode() {
        
        let error = CVVPinErrorMapper.map(.init(errorMessage: "error", retryAttempts: 1))
        
        XCTAssertNoDiff(error.message?.rawValue, String.incorrectСode)
    }
}
