//
//  RequestFactory+createCreateDraftCollateralLoanApplicationRequestTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 27.11.2024.
//

import RemoteServices
import XCTest
@testable import ForaBank

final class RequestFactory_createCreateDraftCollateralLoanApplicationRequestTests: XCTestCase {
    
    func test_createCreateDraftCollateralLoanApplicationRequest_shouldSetRequestURL() throws {
        
        let request = try createCreateDraftCollateralLoanApplicationRequest(anyPayload())
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v1/createDraftCollateralLoanApplication"
        )
    }
    
    func test_createCreateDraftCollateralLoanApplicationRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createCreateDraftCollateralLoanApplicationRequest(anyPayload())
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createCreateDraftCollateralLoanApplicationRequest_shouldSetRequestBody() throws {
        
        let name = UUID().uuidString
        let amount = UInt.random(in: (0...UInt.max))
        let termMonth = UInt.random(in: (0...UInt.max))
        let collateralType = UUID().uuidString
        let interestRate = Double.random(in: (0...Double.greatestFiniteMagnitude))
        let collateralInfo = UUID().uuidString
        let cityName = UUID().uuidString
        let payrollClient = Bool.random()
        
        let payload = anyPayload(
            name: name,
            amount: amount,
            termMonth: termMonth,
            collateralType: collateralType,
            interestRate: interestRate,
            collateralInfo: collateralInfo,
            cityName: cityName,
            payrollClient: payrollClient
        )
        
        let request = try createCreateDraftCollateralLoanApplicationRequest(payload)
        
        let decoded = try JSONDecoder().decode(_Payload.self, from: XCTUnwrap(request.httpBody))
        
        XCTAssertNoDiff(
            decoded,
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
        )
    }
    
    // MARK: - Helpers
    
    private func createCreateDraftCollateralLoanApplicationRequest(
        _ payload: Payload
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateDraftCollateralLoanApplicationRequest(with: payload)
    }
    
    private func anyPayload(
        name: String = UUID().uuidString,
        amount: UInt = .random(in: (0...UInt.max)),
        termMonth: UInt = .random(in: (0...UInt.max)),
        collateralType: String = UUID().uuidString,
        interestRate: Double = .random(in: (0...Double.greatestFiniteMagnitude)),
        collateralInfo: String = UUID().uuidString,
        cityName: String = UUID().uuidString,
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
    
    private struct _Payload: Decodable, Equatable {
        
        let name: String
        let amount: UInt
        let termMonth: UInt
        let collateralType: String
        let interestRate: Double
        let collateralInfo: String
        let cityName: String
        let payrollClient: Bool
    }
    
    typealias Payload = RemoteServices.RequestFactory.CreateDraftCollateralLoanApplicationPayload
}
