//
//  RequestFactory+createCreateAnywayTransferRequestTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPayment
import RemoteServices
import XCTest

final class RequestFactory_createCreateAnywayTransferRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL()
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }
    
    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetHTTPBody() throws {
        
        let payload = makePayload()
        let request = try createRequest(payload: payload)
        
        let body = try request.decodedBody(as: _DTO.self)
        
        XCTAssertEqual(body, _DTO(payload))
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: RequestFactory.CreateAnywayTransferResponsePayload = makePayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateAnywayTransferRequest(
            url: url,
            payload: payload
        )
    }
}

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

private extension _DTO {
    
    init(_ payload: RequestFactory.CreateAnywayTransferResponsePayload) {
        
        self.init(
            additional: payload.additionals.map { .init($0) },
            amount: payload.amount,
            check: payload.check,
            comment: payload.comment,
            currencyAmount: payload.currencyAmount,
            mcc: payload.mcc,
            payer: payload.payer.map { .init($0) },
            puref: payload.puref
        )
    }
}

private extension _DTO._Additional {
    
    init(_ payload: RequestFactory.CreateAnywayTransferResponsePayload.Additional) {
        
        self.init(
            fieldid: payload.fieldID,
            fieldname: payload.fieldName,
            fieldvalue: payload.fieldValue
        )
    }
}

private extension _DTO._Payer {
    
    init(_ payer: RequestFactory.CreateAnywayTransferResponsePayload.Payer) {
        
        self.init(
            accountId: payer.accountID,
            accountNumber: payer.accountNumber,
            cardId: payer.cardID,
            cardNumber: payer.cardNumber,
            inn: payer.inn,
            phoneNumber: payer.phoneNumber
        )
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
) -> RequestFactory.CreateAnywayTransferResponsePayload {
    
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
