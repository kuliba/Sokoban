//
//  RequestFactory+createCreateAnywayTransferRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.03.2024.
//

import AnywayPayment
import Foundation
import RemoteServices

extension Services.Endpoint {
    
    static let createAnywayTransfer: Self = .init(
        pathPrefix: .transfer,
        version: nil,
        serviceName: .createAnywayTransfer
    )
}

extension ForaBank.RequestFactory {
    
    static func createCreateAnywayTransferRequest(
        _ payload: RemoteServices.RequestFactory.CreateAnywayTransferResponsePayload
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createAnywayTransfer
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createCreateAnywayTransferRequest(
            url: endpointURL,
            payload: payload
        )
    }
}

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_createCreateAnywayTransferRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/transfer/createAnywayTransfer"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let (fieldID, fieldName, fieldValue) = makeFields()
        let accountID = generateRandom11DigitNumber()
        let request = try createRequest(payload: makePayload(
            accountID: accountID,
            fieldID: fieldID,
            fieldName: fieldName,
            fieldValue: fieldValue
        ))
        let decodedRequest = try JSONDecoder().decode(
            _DTO.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest, .init(
            additional: [
                .init(
                    fieldid: fieldID,
                    fieldname: fieldName,
                    fieldvalue: fieldValue
                )
            ],
            amount: nil,
            check: false,
            comment: nil,
            currencyAmount: nil,
            mcc: nil,
            payer: .init(
                accountId: accountID,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                inn: nil,
                phoneNumber: nil
            ),
            puref: nil
        ))
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        payload: CreateAnywayTransferResponsePayload = makePayload()
    ) throws -> URLRequest {
        
        try ForaBank.RequestFactory.createCreateAnywayTransferRequest(payload)
    }
    
    private func makeFields() -> (Int, String, String) {
        
        (generateRandom11DigitNumber(), UUID().uuidString, UUID().uuidString)
    }
}

private typealias CreateAnywayTransferResponsePayload = RemoteServices.RequestFactory.CreateAnywayTransferResponsePayload

private struct _DTO: Decodable, Equatable {
    
    let additional: [_Additional]
    let amount: Decimal?
    let check: Bool
    let comment: String?
    let currencyAmount: String?
    let mcc: String?
    let payer: _Payer?
    let puref: String?
    
    struct _Additional: Decodable, Equatable {
        
        let fieldid: Int
        let fieldname: String
        let fieldvalue: String
    }
    
    struct _Payer: Decodable, Equatable {
        
        let accountId: Int?
        let accountNumber: String?
        let cardId: Int?
        let cardNumber: String?
        let inn: String?
        let phoneNumber: String?
    }
}

private func makePayload(
    accountID: Int? = nil,
    accountNumber: String? = nil,
    amount: Decimal? = nil,
    cardID: Int? = nil,
    cardNumber: String? = nil,
    comment: String? = nil,
    currencyAmount: String? = nil,
    fieldID: Int = generateRandom11DigitNumber(),
    fieldName: String = UUID().uuidString,
    fieldValue: String = UUID().uuidString,
    inn: String? = nil,
    mcc: String? = nil,
    phoneNumber: String? = nil,
    puref: String? = nil
) -> CreateAnywayTransferResponsePayload {
    
    .init(
        additionals: [
            .init(
                fieldID: fieldID,
                fieldName: fieldName,
                fieldValue: fieldValue
            )
        ],
        amount: amount,
        check: false,
        comment: comment,
        currencyAmount: currencyAmount,
        mcc: mcc,
        payer: .init(
            accountID: accountID,
            accountNumber: accountNumber,
            cardID: cardID,
            cardNumber: cardNumber,
            inn: inn,
            phoneNumber: phoneNumber
        ),
        puref: puref
    )
}

#warning("move to shared scope")
func generateRandom11DigitNumber() -> Int {
    
    let firstDigit = Int.random(in: 1...9)
    let remainingDigits = (1..<11)
        .map { _ in Int.random(in: 0...9) }
        .reduce(0, { $0 * 10 + $1 })
    
    return firstDigit * Int(pow(10.0, 10.0)) + remainingDigits
}
