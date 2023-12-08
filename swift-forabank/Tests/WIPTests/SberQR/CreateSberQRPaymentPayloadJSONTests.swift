//
//  CreateSberQRPaymentPayloadJSONTests.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import XCTest

private extension CreateSberQRPaymentPayload {
    
    var json: Data {
        
        get throws {
            
            var parameters: [[String: String]] = [[
                "id": "QRLink",
                "value": qrLink.absoluteString
            ],[
                "id": idID,
                "value": "\(idValue)"
            ]]
            
            let amount: [[String: String]]? = amount.map { [[
                "id": "payment_amount",
                "value": "\($0.amount)"
            ],[
                "id": "currency",
                "value": $0.currency.rawValue
            ]] }
            if let amount { parameters.append(contentsOf: amount)}
            
            return try JSONSerialization.data(withJSONObject: [
                "parameters": parameters
            ] as [String: Any])
        }
    }
    
    private var idID: String {
        
        switch product {
        case .card:
            return "cardId"
            
        case .account:
            return "accountId"
        }
    }
    
    private var idValue: Int {
        
        switch product {
        case let .card(cardID):
            return cardID.rawValue
            
        case let .account(accountID):
            return accountID.rawValue
        }
    }
}

final class CreateSberQRPaymentPayloadJSONTests: XCTestCase {
    
    func test_payload_json_cardIDWithoutAmount() throws {
        
        let payload = makePayload()
        
        let json = try payload.json
        let decoded = try JSONDecoder().decode(Payload.self, from: json)
        
        XCTAssertNoDiff(decoded, .init(parameters: [
            .init(id: "QRLink", value: "https://platiqr.ru/?uuid=1000101124"),
            .init(id: "cardId", value: "12345677889900"),
        ]))
    }
    
    func test_payload_json_accountIDWithoutAmount() throws {
        
        let payload = makePayload(type: .account)
        
        let json = try payload.json
        let decoded = try JSONDecoder().decode(Payload.self, from: json)
        
        XCTAssertNoDiff(decoded, .init(parameters: [
            .init(id: "QRLink", value: "https://platiqr.ru/?uuid=1000101124"),
            .init(id: "accountId", value: "12345677889900"),
        ]))
    }
    
    func test_payload_json_cardIDWithAmount() throws {
        
        let payload = makePayload(amount: (1234.35, "RUB"))
        
        let json = try payload.json
        let decoded = try JSONDecoder().decode(Payload.self, from: json)
        
        XCTAssertNoDiff(decoded, .init(parameters: [
            .init(id: "QRLink", value: "https://platiqr.ru/?uuid=1000101124"),
            .init(id: "cardId", value: "12345677889900"),
            .init(id: "payment_amount", value: "1234.35"),
            .init(id: "currency", value: "RUB"),
        ]))
    }
    
    func test_payload_json_accountIDWithAmount() throws {
        
        let payload = makePayload(
            type: .account,
            amount: (1234.35, "RUB")
        )
        
        let json = try payload.json
        let decoded = try JSONDecoder().decode(Payload.self, from: json)
        
        XCTAssertNoDiff(decoded, .init(parameters: [
            .init(id: "QRLink", value: "https://platiqr.ru/?uuid=1000101124"),
            .init(id: "accountId", value: "12345677889900"),
            .init(id: "payment_amount", value: "1234.35"),
            .init(id: "currency", value: "RUB"),
        ]))
    }
    
    // MARK: - Helpers
    
    private func makePayload(
        _ urlString: String = "https://platiqr.ru/?uuid=1000101124",
        type: ProductType = .card,
        id: Int = 12345677889900,
        amount: (amount: Decimal, currency: String)? = nil
    ) -> CreateSberQRPaymentPayload {
        
        .init(
            qrLink: anyURL(urlString),
            product: type.product(id: id),
            amount: amount.map {
                
                .init(
                    amount: $0.amount,
                    currency: .init($0.currency)
                )
            }
        )
    }
    
    private enum ProductType {
        
        case card, account
        
        func product(id: Int) -> CreateSberQRPaymentPayload.Product {
            
            switch self {
            case .card:
                return .card(.init(id))

            case .account:
                return .account(.init(id))
            }
        }
    }
    
    private struct Payload: Decodable, Equatable {
        
        let parameters: [Parameter]
        
        struct Parameter: Decodable, Equatable {
            
            let id: String
            let value: String
        }
    }
}
