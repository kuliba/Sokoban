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
    
    func test_json_shouldDeliverDataWithEmptyOnEmpty() throws {
        
        let digest = makeAnywayPaymentDigest(check: false, additional: [])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            check: false,
            amount: nil,
            currencyAmount: nil,
            payer: nil,
            comment: nil,
            puref: nil,
            additional: [],
            mcc: nil
        ))
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
        let digest = makeAnywayPaymentDigest(check: false, additional: [additional])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            check: false,
            amount: nil,
            currencyAmount: nil,
            payer: nil,
            comment: nil,
            puref: nil,
            additional: [
                .init(
                    fieldid: fieldID,
                    fieldname: fieldName,
                    fieldvalue: fieldValue
                )
            ],
            mcc: nil
        ))
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
        let digest = makeAnywayPaymentDigest(check: false, additional: [
            firstAdditional,
            secondAdditional
        ])
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            check: false,
            amount: nil,
            currencyAmount: nil,
            payer: nil,
            comment: nil,
            puref: nil,
            additional: [
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
            ],
            mcc: nil
        ))
    }
    
    func test_json_shouldDeliverDataWithCardID() throws {
        
        let cardIDRawValue = generateRandom11DigitNumber()
        let comment = anyMessage()
        let purefRawValue = anyMessage()
        let mccRawValue = anyMessage()
        let digest = makeAnywayPaymentDigest(
            check: true,
            amount: .init(
                value: 1_234.56,
                currency: "RUB"
            ),
            product: .card(.init(cardIDRawValue)),
            comment: comment,
            puref: .init(purefRawValue),
            additional: [],
            mcc: .init(mccRawValue)
        )
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            check: true,
            amount: 1_234.56,
            currencyAmount: "RUB",
            payer: .init(
                cardId: cardIDRawValue,
                accountId: nil
            ),
            comment: comment,
            puref: purefRawValue,
            additional: [],
            mcc: mccRawValue
        ))
    }
    
    func test_json_shouldDeliverDataWithAccountID() throws {
        
        let accountIDRawValue = generateRandom11DigitNumber()
        let comment = anyMessage()
        let purefRawValue = anyMessage()
        let mccRawValue = anyMessage()
        let digest = makeAnywayPaymentDigest(
            check: true,
            amount: .init(
                value: 1_234.56,
                currency: "RUB"
            ),
            product: .account(.init(accountIDRawValue)),
            comment: comment,
            puref: .init(purefRawValue),
            additional: [],
            mcc: .init(mccRawValue)
        )
        
        let decoded = try JSONDecoder().decode(_DTO.self, from: digest.json)
        
        XCTAssertNoDiff(decoded, .init(
            check: true,
            amount: 1_234.56,
            currencyAmount: "RUB",
            payer: .init(
                cardId: nil,
                accountId: accountIDRawValue
            ),
            comment: comment,
            puref: purefRawValue,
            additional: [],
            mcc: mccRawValue
        ))
    }
    
    // MARK: - Helpers
    
    private func makeAnywayPaymentDigest(
        check: Bool,
        amount: AnywayPaymentDigest.Amount? = nil,
        product: AnywayPaymentDigest.Product? = nil,
        comment: String? = nil,
        puref: AnywayPaymentDigest.Puref? = nil,
        additional: [AnywayPaymentDigest.Additional],
        mcc: AnywayPaymentDigest.MCC? = nil
    ) -> AnywayPaymentDigest {
        
        .init(
            check: check,
            amount: amount,
            product: product,
            comment: comment,
            puref: puref,
            additional: additional,
            mcc: mcc
        )
    }
    
    private struct _DTO: Decodable, Equatable {
        
        let check: Bool
        let amount: Decimal?
        let currencyAmount: String?
        let payer: Payer?
        let comment: String?
        let puref: String?
        let additional: [Additional]
        let mcc: String?
        
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
