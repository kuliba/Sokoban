//
//  RequestFactory+createCreateSberQRPaymentRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class RequestFactory_createCreateSberQRPaymentRequestTests: XCTestCase {
    
    func test_createCreateSberQRPaymentRequest_shouldSetRequestURL() throws {
        
        let request = try createCreateSberQRPaymentRequest()
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/binding/v1/createSberQRPayment"
        )
    }
    
    func test_createCreateSberQRPaymentRequest_shouldSetRequestMethodToPost() throws {
        
        let request = try createCreateSberQRPaymentRequest()
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_createCreateSberQRPaymentRequest_shouldSetRequestBodyWithoutAmountOnNilAmount() throws {
        
        let url = anyURL()
        let amount: CreateSberQRPaymentPayload.Amount? = nil
        let payload = anyCreateSberQRPaymentPayload(
            qrLink: url,
            product: .account(56789),
            amount: amount
        )
        let request = try createCreateSberQRPaymentRequest(payload: payload)
        let data = try XCTUnwrap(request.httpBody)
        let decoded = try JSONDecoder().decode(Payload.self, from: data)
        
        XCTAssertNoDiff(decoded.parameters, [
            .init(id: "QRLink", value: url.absoluteString),
            .init(id: "accountId", value: "56789"),
        ])
    }
    
    func test_createCreateSberQRPaymentRequest_shouldSetRequestBodyWithAmountOnNonNilAmount() throws {
        
        let url = anyURL()
        let amountValue: Decimal = 123456.78
        let currency: CreateSberQRPaymentPayload.Amount.Currency = "USD"
        let amount = CreateSberQRPaymentPayload.Amount(
            amount: amountValue,
            currency: currency
        )
        let payload = anyCreateSberQRPaymentPayload(
            qrLink: url,
            product: .account(56789),
            amount: amount
        )
        let request = try createCreateSberQRPaymentRequest(payload: payload)
        let data = try XCTUnwrap(request.httpBody)
        let decoded = try JSONDecoder().decode(Payload.self, from: data)
        
        XCTAssertNoDiff(decoded.parameters, [
            .init(id: "QRLink", value: url.absoluteString),
            .init(id: "accountId", value: "56789"),
            .init(id: "payment_amount", value: "\(amountValue)"),
            .init(id: "currency", value: currency.rawValue),
        ])
    }
    
    // MARK: - Helpers
    
    private func createCreateSberQRPaymentRequest(
        payload: CreateSberQRPaymentPayload = anyCreateSberQRPaymentPayload()
    ) throws -> URLRequest {
        
        try RequestFactory.createCreateSberQRPaymentRequest(payload: payload)
    }
    
    private struct Payload: Decodable {
        
        let parameters: [Parameter]
        
        struct Parameter: Decodable, Equatable {
            
            let id: String
            let value: String
        }
    }
}

private func anyCreateSberQRPaymentPayload(
    qrLink: URL = anyURL(),
    product: CreateSberQRPaymentPayload.Product = .card(123456789),
    amount: CreateSberQRPaymentPayload.Amount? = nil
) -> CreateSberQRPaymentPayload {
    
    .init(
        qrLink: qrLink,
        product: product,
        amount: amount
    )
}
