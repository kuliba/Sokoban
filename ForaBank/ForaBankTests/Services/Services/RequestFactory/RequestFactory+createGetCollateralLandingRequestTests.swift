//
//  RequestFactory+createGetCollateralLandingRequestTests.swift
//  ForaBankTests
//
//  Created by Valentin Ozerov on 29.11.2024.
//

@testable import ForaBank
import XCTest
import CollateralLoanLandingGetCollateralLandingBackend
import RemoteServices

final class RequestFactory_createGetCollateralLandingRequestTests: XCTestCase {
    
    func test_createGetCollateralLandingRequest_shouldSetRequestURL() throws {
        
        let serial = UUID().uuidString
        let landingType = randomLandingType
        
        let request = try createRequest(serial: serial, landingType: landingType)
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v1/pages/collateral/getCollateralLanding"
        )
    }
    
    func test_createGetCollateralLandingRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createGetCollateralLandingRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        serial: String = UUID().uuidString,
        landingType: LandingType = [LandingType.car, LandingType.realEstate].randomElement() ?? .car,
        _ operatorID: String = UUID().uuidString
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCollateralLandingRequest(
            serial: serial,
            landingType: landingType
        )
    }
    
    private var randomLandingType: LandingType {
        
        [LandingType.car, LandingType.realEstate].randomElement() ?? .car
    }
    
    typealias LandingType = RemoteServices.RequestFactory.CollateralLoanLandingType
}
