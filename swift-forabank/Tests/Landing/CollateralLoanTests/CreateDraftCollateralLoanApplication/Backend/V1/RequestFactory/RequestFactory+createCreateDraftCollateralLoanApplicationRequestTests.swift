//
//  RequestFactory+createCreateDraftCollateralLoanApplicationRequestTests.swift
//
//
//  Created by Valentin Ozerov on 28.11.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingCreateDraftCollateralLoanApplicationBackend

final class RequestFactory_createCreateDraftCollateralLoanApplicationRequestTests: XCTestCase {
    
    func test_createCollateralLoanLandingSaveConsentsRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try RequestFactory.createCreateDraftCollateralLoanApplicationRequest(
            url: anyURL(),
            payload: anyPayload()
        )
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createCollateralLoanLandingSaveConsentsRequest_shouldSetCachePolicy() throws {
        
        let request = try RequestFactory.createCreateDraftCollateralLoanApplicationRequest(
            url: anyURL(),
            payload: anyPayload()
        )

        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createCollateralLoanLandingSaveConsentsRequest_shouldSetWithHTTPBody() throws {

        let payload = anyPayload()
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: Body.self)
        XCTAssertNoDiff(body.payload, payload)
    }
}

extension RequestFactory_createCreateDraftCollateralLoanApplicationRequestTests {
    
    typealias Payload = RequestFactory.CreateDraftCollateralLoanApplicationPayload
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: Payload
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateDraftCollateralLoanApplicationRequest(
            url: url,
            payload: payload
        )
    }
    
    private func anyPayload(
        name: String = anyMessage(),
        amount: UInt = .random(in: (0...UInt.max)),
        termMonth: UInt = .random(in: (0...UInt.max)),
        collateralType: String = anyMessage(),
        interestRate: Double = .random(in: (0...Double.greatestFiniteMagnitude)),
        collateralInfo: String = anyMessage(),
        cityName: String = anyMessage(),
        payrollClient: Bool = .random()
    ) -> Payload {
        
        .init(
            name: name,
            amount: amount,
            termMonth: termMonth,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            cityName: cityName,
            payrollClient: payrollClient
        )
    }
    
    private struct Body: Decodable {
        
        let name: String
        let amount: UInt
        let termMonth: UInt
        let collateralType: String
        let interestRate: Double
        let collateralInfo: String
        let cityName: String
        let payrollClient: Bool

        var payload: Payload {
            
            .init(
                name: name,
                amount: amount,
                termMonth: termMonth,
                collateralType: collateralType,
                interestRate: interestRate,
                collateralInfo: collateralInfo,
                cityName: cityName,
                payrollClient: payrollClient
            )
        }
    }
}
