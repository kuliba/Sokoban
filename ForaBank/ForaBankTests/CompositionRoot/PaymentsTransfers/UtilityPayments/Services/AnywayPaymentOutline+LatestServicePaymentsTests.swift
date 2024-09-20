//
//  AnywayPaymentOutline+LatestServicePaymentsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.06.2024.
//

@testable import ForaBank
import AnywayPaymentDomain
import LatestPaymentsBackendV2
import RemoteServices

import XCTest

final class AnywayPaymentOutline_LatestServicePaymentsTests: XCTestCase {
    
    func test_init_shouldNotSetAmount() throws {
        
        let latest = try makeLatestPayment()
        
        let outline = makeOutline(latest)
        
        XCTAssertNil(outline.amount)
    }
    
    func test_init_shouldSetFields() throws {
        
        let latest = try makeLatestPayment()
        
        let outline = makeOutline(latest)
        
        XCTAssertNoDiff(outline.fields, [
            "1": "100062",
            "2": "0121",
            "8": " ",
            "12": " ",
            "SumSTrs": "777",
        ])
    }
    
    func test_init_shouldSetPayload() throws {
        
        let latest = try makeLatestPayment()
        
        let outline = makeOutline(latest)
        
        XCTAssertNoDiff(outline.payload, .init(
            puref: "iForaNKORR||18650",
            title: "МУП АГО АНГАРСКИЙ ВОДОКАНАЛ",
            subtitle: nil,
            icon: "1efeda3c9130101d4d88113853b03bb5"
        ))
    }
    
    // MARK: - Helpers
    
    private typealias LatestPayment = RemoteServices.ResponseMapper.LatestServicePayment
    private typealias Outline = AnywayPaymentOutline
    
    private func makeOutline(
        _ latestPayment: LatestPayment,
        product: Outline.Product? = nil
    ) -> Outline {
        
        return .init(
            latestServicePayment: latestPayment, 
            product: product ?? makeOutlineProduct()
        )
    }
    
    private func makeOutlineProduct(
        currency: String = anyMessage(),
        productID: Int = .random(in: 1...100),
        productType: AnywayPaymentOutline.Product.ProductType = .card
    ) -> AnywayPaymentOutline.Product {
        
        return .init(currency: currency, productID: productID, productType: productType)
    }
    
    private func makeLatestPayment() throws -> LatestPayment {
        
        try makeLatestPayment(
            date: makeDate(28, 06, 2024, 20, 19, 21),
            amount: 777,
            name: "МУП АГО АНГАРСКИЙ ВОДОКАНАЛ",
            md5Hash: "1efeda3c9130101d4d88113853b03bb5",
            puref: "iForaNKORR||18650",
            additionalItems: [
                makeAdditionalItem(
                    fieldName: "1",
                    fieldValue: "100062"
                ),
                makeAdditionalItem(
                    fieldName: "2",
                    fieldValue: "0121"
                ),
                makeAdditionalItem(
                    fieldName: "8",
                    fieldValue: " "
                ),
                makeAdditionalItem(
                    fieldName: "12",
                    fieldValue: " "
                ),
                makeAdditionalItem(
                    fieldName: "SumSTrs",
                    fieldValue: "777"
                ),
            ]
        )
    }
    
    private func makeLatestPayment(
        date: Date,
        amount: Decimal,
        name: String,
        md5Hash: String?,
        puref: String,
        additionalItems: [LatestPayment.AdditionalItem]
    ) -> LatestPayment {
        
        return .init(
            date: date,
            amount: amount,
            name: name,
            md5Hash: md5Hash,
            puref: puref,
            additionalItems: additionalItems
        )
    }
    
    private func makeAdditionalItem(
        fieldName: String,
        fieldValue: String,
        fieldTitle: String? = nil,
        svgImage: String? = nil
    ) -> LatestPayment.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
    
    private func makeDate(
        _ day: Int,
        _ month: Int,
        _ year: Int,
        _ hour: Int,
        _ minute: Int,
        _ second: Int
    ) throws -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let calendar = Calendar(identifier: .gregorian)
        return try XCTUnwrap(calendar.date(from: dateComponents))
    }
}
