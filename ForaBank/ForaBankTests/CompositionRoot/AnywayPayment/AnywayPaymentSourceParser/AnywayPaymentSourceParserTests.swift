//
//  AnywayPaymentSourceParserTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentDomain
import RemoteServices

final class AnywayPaymentSourceParser {
    
    private let getOutlineProduct: GetOutlineProduct
    
    init(
        getOutlineProduct: @escaping GetOutlineProduct
    ) {
        self.getOutlineProduct = getOutlineProduct
    }
    
    typealias GetOutlineProduct = () -> AnywayPaymentOutline.Product?
}

extension AnywayPaymentSourceParser {
    
    enum Source: Equatable {
        
        case latest(Latest)
        
        typealias Latest = RemoteServices.ResponseMapper.LatestServicePayment
    }
    
    struct Output: Equatable {
        
        let outline: AnywayPaymentOutline
        let firstField: AnywayElement.Field?
    }
    
    func parse(source: Source) throws -> Output {
        
        guard let product = getOutlineProduct(for: source)
        else { throw ParsingError.missingProduct }
        
        switch source {
        case let .latest(latest):
            return .init(
                outline: .init(
                    latestServicePayment: latest,
                    product: product
                ),
                firstField: nil
            )
        }
    }
    
    enum ParsingError: Error, Equatable {
        
        case missingProduct
    }
}

private extension AnywayPaymentSourceParser {
    
    func getOutlineProduct(
        for source: Source
    ) -> AnywayPaymentOutline.Product? {
        
        getOutlineProduct()
    }
}

@testable import ForaBank
import XCTest

final class AnywayPaymentSourceParserTests: XCTestCase {
    
    // MARK: - latest
    
    func test_parse_latest_shouldDeliverOutlineProductErrorOnMissingOutlineProduct() throws {
        
        let sut = makeSUT(outlineProduct: nil)
        
        try XCTAssertThrowsError(sut.parse(source: latest())) {
            
            XCTAssertNoDiff($0 as? SUT.ParsingError, .missingProduct)
        }
    }
    
    func test_parse_latest_shouldSetOutlineAmount() throws {
        
        let amount = anyAmount()
        let source = latest(amount: amount)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.amount, amount)
    }
    
    func test_parse_latest_shouldSetOutlineProduct() throws {
        
        let product = makeOutlineProduct()
        let sut = makeSUT(outlineProduct: product)
        let source = latest()
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output.outline.product, product)
    }
    
    func test_parse_latest_shouldSetEmptyOutlineFieldsOnEmptyFields() throws {
        
        let source = latest(additionalItems: [])
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, .init())
    }
    
    func test_parse_latest_shouldSetOutlineOneFieldOnOne() throws {
        
        let (name, value) = (anyMessage(), anyMessage())
        let additional = makeAdditional(fieldName: name, fieldValue: value)
        let source = latest(additionalItems: [additional])
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, [name: value])
    }
    
    func test_parse_latest_shouldSetOutlineFields() throws {
        
        let (name1, value1) = (anyMessage(), anyMessage())
        let (name2, value2) = (anyMessage(), anyMessage())
        let additional1 = makeAdditional(fieldName: name1, fieldValue: value1)
        let additional2 = makeAdditional(fieldName: name2, fieldValue: value2)
        let source = latest(additionalItems: [additional1, additional2])
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, [
            name1: value1,
            name2: value2,
        ])
    }
    
    func test_parse_latest_shouldSetOutlinePayloadPuref() throws {
        
        let puref = anyMessage()
        let source = latest(puref: puref)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.puref, puref)
    }
    
    func test_parse_latest_shouldSetOutlinePayloadTitle() throws {
        
        let title = anyMessage()
        let source = latest(title: title)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.title, title)
    }
    
    func test_parse_latest_shouldSetNilOutlinePayloadSubtitle() throws {
        
        let source = latest()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_latest_shouldSetNilOutlinePayloadIconOnNil() throws {
        
        let source = latest(icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_latest_shouldSetOutlinePayloadIcon() throws {
        
        let icon = anyMessage()
        let source = latest(icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.icon, icon)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentSourceParser
    private typealias OutlineProduct = AnywayPaymentOutline.Product
    private typealias Latest = AnywayPaymentSourceParser.Source.Latest
    
    private func makeSUT(
        outlineProduct: OutlineProduct? = makeOutlineProduct(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(getOutlineProduct: { outlineProduct })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func latest(
        additionalItems: [Latest.AdditionalItem] = [],
        amount: Decimal = anyAmount(),
        icon: String? = nil,
        puref: String = anyMessage(),
        title: String = anyMessage()
    ) -> AnywayPaymentSourceParser.Source {
        
        return .latest(makeLatestPayment(
            additionalItems: additionalItems,
            amount: amount,
            date: .init(),
            icon: icon,
            puref: puref,
            title: title
        ))
    }
    
    private func makeLatestPayment(
        additionalItems: [Latest.AdditionalItem] = [],
        amount: Decimal = anyAmount(),
        date: Date = .init(),
        icon: String? = anyMessage(),
        puref: String = anyMessage(),
        title: String = anyMessage()
    ) -> Latest {
        
        return .init(
            date: date,
            amount: amount,
            name: title,
            md5Hash: icon,
            puref: puref,
            additionalItems: additionalItems
        )
    }
    
    private func makeAdditional(
        fieldName: String = anyMessage(),
        fieldValue: String = anyMessage(),
        fieldTitle: String? = nil,
        svgImage: String? = nil
    ) -> Latest.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
}

func anyAmount(
    _ value: Double = .random(in: 1...1_000)
) -> Decimal {
    
    return .init(value)
}
