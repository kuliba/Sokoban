//
//  RequestFactory+createGetCollateralLandingRequestTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 29.11.2024.
//

@testable import Vortex
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
            "https://pl.\(Config.domen)/dbo/api/v3/rest/v1/pages/collateral/getCollateralLanding?landingTypes=\(landingType.rawValue)&serial=\(serial)"
        )
    }

    func test_createGetCollateralLandingRequest_shouldBeEmptySerialInRequestWithNoSerialInParameters() throws {
        
        let landingType = randomLandingType

        let queryItems = try getQueryItems(serial: nil, landingType: landingType)

        XCTAssertNil(queryItems.first { $0.name == "serial" }?.value)
        XCTAssertNoDiff(queryItems.first { $0.name == "landingTypes" }?.value, landingType.rawValue)
    }

    func test_createGetCollateralLandingRequest_shouldBeEqualParams() throws {
        
        let landingType = randomLandingType
        let serial = anyMessage()

        let queryItems = try getQueryItems(serial: serial, landingType: landingType)

        XCTAssertNoDiff(queryItems.first { $0.name == "serial" }?.value, serial)
        XCTAssertNoDiff(queryItems.first { $0.name == "landingTypes" }?.value, landingType.rawValue)
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
        serial: String? = UUID().uuidString,
        landingType: LandingType = [LandingType.car, LandingType.realEstate].randomElement() ?? .car
    ) throws -> URLRequest {
        
        try RequestFactory.createGetCollateralLandingRequest(
            serial: serial,
            landingType: landingType
        )
    }
    
    private func getQueryItems(serial: String?, landingType: LandingType) throws -> [URLQueryItem] {

        let request = try createRequest(serial: serial, landingType: landingType)
        
        let requestUrl = try XCTUnwrap(request.url)
        let urlComponents = try XCTUnwrap(URLComponents(url: requestUrl, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(urlComponents.queryItems)

        return queryItems
    }

    private var randomLandingType: LandingType {
        
        [LandingType.car, LandingType.realEstate].randomElement() ?? .car
    }
    
    typealias LandingType = RemoteServices.RequestFactory.CollateralLoanLandingType
}
