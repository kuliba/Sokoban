//
//  AnywayPaymentDigestTests.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentCore
import XCTest

final class AnywayPaymentDigestTests: XCTestCase {
    
    func test_json_shouldDeliverDataWithPuref() throws {
        
        let purefRawValue = anyMessage()
        let digest = makeAnywayPaymentDigest(purefRawValue: purefRawValue)
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded.puref, .init(purefRawValue))
    }
    
    func test_json_shouldDeliverDataWithEmptyAdditionalOnEmpty() throws {
        
        let digest = makeAnywayPaymentDigest(additional: [])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded.additional, [])
    }
    
    func test_json_shouldDeliverDataWithOneAdditional() throws {
        
        let fieldID = generateRandom11DigitNumber()
        let fieldName = anyMessage()
        let fieldValue = anyMessage()
        
        let additional = AnywayPaymentDigest.Additional(
            fieldID: fieldID,
            fieldName: fieldName,
            fieldValue: fieldValue
        )
        
        let digest = makeAnywayPaymentDigest(additional: [additional])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded.additional, [
            .init(
                fieldid: fieldID,
                fieldname: fieldName,
                fieldvalue: fieldValue
            )
        ])
    }
    
    func test_json_shouldDeliverDataWithTwoAdditional() throws {
        
        let firstFieldID = generateRandom11DigitNumber()
        let firstFieldName = anyMessage()
        let firstFieldValue = anyMessage()
        let secondFieldID = generateRandom11DigitNumber()
        let secondFieldName = anyMessage()
        let secondFieldValue = anyMessage()
        
        let firstAdditional = AnywayPaymentDigest.Additional(
            fieldID: firstFieldID,
            fieldName: firstFieldName,
            fieldValue: firstFieldValue
        )
        let secondAdditional = AnywayPaymentDigest.Additional(
            fieldID: secondFieldID,
            fieldName: secondFieldName,
            fieldValue: secondFieldValue
        )
        
        let digest = makeAnywayPaymentDigest(additional: [
            firstAdditional,
            secondAdditional,
        ])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded.additional, [
            .init(
                fieldid: firstFieldID,
                fieldname: firstFieldName,
                fieldvalue: firstFieldValue
            ),
            .init(
                fieldid: secondFieldID,
                fieldname: secondFieldName,
                fieldvalue: secondFieldValue
            )
        ])
    }
    
    func test_json_shouldDeliverDataWithCardID() throws {
        
        let cardIDRawValue = generateRandom11DigitNumber()
        let purefRawValue = anyMessage()
        let digest = makeAnywayPaymentDigest(
            additional: [],
            core: .init(
                amount: 1_234.56,
                currency: "RUB",
                productID: .card(.init(cardIDRawValue))
            ),
            purefRawValue: purefRawValue
        )
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            amount: 1_234.56,
            currencyAmount: "RUB",
            payer: .init(
                cardId: cardIDRawValue,
                accountId: nil
            ),
            puref: purefRawValue,
            additional: []
        ))
    }
    
    func test_json_shouldDeliverDataWithAccountID() throws {
        
        let accountIDRawValue = generateRandom11DigitNumber()
        let purefRawValue = anyMessage()
        let digest = makeAnywayPaymentDigest(
            additional: [],
            core: .init(
                amount: 1_234.56,
                currency: "RUB",
                productID: .account(.init(accountIDRawValue))
            ),
            purefRawValue: purefRawValue
        )
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            amount: 1_234.56,
            currencyAmount: "RUB",
            payer: .init(
                cardId: nil,
                accountId: accountIDRawValue
            ),
            puref: purefRawValue,
            additional: []
        ))
    }
    
    // MARK: - Helpers
    
    private func makeAnywayPaymentDigest(
        additional: [AnywayPaymentDigest.Additional] = [],
        core: AnywayPaymentDigest.PaymentCore? = nil,
        purefRawValue: String = anyMessage()
    ) -> AnywayPaymentDigest {
        
        .init(additional: additional, core: core, puref: .init(purefRawValue))
    }
    
    private struct _DTO: Decodable, Equatable {
        
        let amount: Decimal?
        let currencyAmount: String?
        let payer: Payer?
        let puref: String
        let additional: [Additional]
        
        struct Additional: Decodable, Equatable {
            
            let fieldid: Int
            let fieldname: String
            let fieldvalue: String
        }
        
        struct Payer: Decodable, Equatable {
            
            let cardId: Int?
            let accountId: Int?
        }
    }
}
