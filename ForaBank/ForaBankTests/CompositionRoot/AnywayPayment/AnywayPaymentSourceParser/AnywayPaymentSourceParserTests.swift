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
        case oneOf(Service, Operator)
        case picked(ServicePickerItem, PaymentProviderServicePickerPayload)
        case single(Service, Operator)
        
        typealias Latest = RemoteServices.ResponseMapper.LatestServicePayment
        typealias Operator = UtilityPaymentOperator
        typealias Service = UtilityService
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
            
        case let .oneOf(service, `operator`):
            return .init(
                outline: .init(
                    operator: `operator`,
                    puref: service.puref,
                    product: product
                ),
                firstField: .init(
                    service: service,
                    icon: `operator`.icon
                )
            )
            
        case let .picked(item, payload):
            return .init(
                outline: .init(
                    service: item.service,
                    payload: payload,
                    product: product
                ),
                firstField: .init(
                    service: item.isOneOf ? item.service : nil,
                    icon: payload.provider.origin.icon
                )
            )
            
        case let .single(service, `operator`):
            return .init(
                outline: .init(
                    operator: `operator`,
                    puref: service.puref,
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
    
    func test_parse_latest_shouldSetFirstFieldToNil() throws {
        
        let source = latest()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.firstField)
    }
    
    func test_parse_latest_shouldDeliverOutput() throws {
        
        let amount = anyAmount()
        let product = makeOutlineProduct()
        let (name, value) = (anyMessage(), anyMessage())
        let additional = makeAdditional(fieldName: name, fieldValue: value)
        let (puref, title, icon) = (anyMessage(), anyMessage(), anyMessage())
        let source = latest(
            additionalItems: [additional],
            amount: amount,
            icon: icon,
            puref: puref,
            title: title
        )
        let sut = makeSUT(outlineProduct: product)
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output, .init(
            outline: .init(
                amount: amount,
                product: product,
                fields: [name: value],
                payload: .init(
                    puref: puref,
                    title: title,
                    subtitle: nil,
                    icon: icon
                )
            ),
            firstField: nil
        ))
    }
    
    // MARK: - oneOf
    
    func test_parse_oneOf_shouldDeliverOutlineProductErrorOnMissingOutlineProduct() throws {
        
        let sut = makeSUT(outlineProduct: nil)
        
        try XCTAssertThrowsError(sut.parse(source: oneOf())) {
            
            XCTAssertNoDiff($0 as? SUT.ParsingError, .missingProduct)
        }
    }
    
    func test_parse_oneOf_shouldSetOutlineAmountToNil() throws {
        
        let source = oneOf()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.amount)
    }
    
    func test_parse_oneOf_shouldSetOutlineProduct() throws {
        
        let product = makeOutlineProduct()
        let sut = makeSUT(outlineProduct: product)
        let source = oneOf()
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output.outline.product, product)
    }
    
    func test_parse_oneOf_shouldSetEmptyOutlineFields() throws {
        
        let source = oneOf()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, .init())
    }
    
    func test_parse_oneOf_shouldSetOutlinePayloadPuref() throws {
        
        let puref = anyMessage()
        let source = oneOf(puref: puref)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.puref, puref)
    }
    
    func test_parse_oneOf_shouldSetOutlinePayloadTitle() throws {
        
        let title = anyMessage()
        let source = oneOf(title: title)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.title, title)
    }
    
    func test_parse_oneOf_shouldSetNilOutlinePayloadSubtitle() throws {
        
        let source = oneOf()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_oneOf_shouldSetOutlinePayloadSubtitle() throws {
        
        let subtitle = anyMessage()
        let source = oneOf(subtitle: subtitle)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.subtitle, subtitle)
    }
    
    func test_parse_oneOf_shouldSetNilOutlinePayloadIconOnNil() throws {
        
        let source = oneOf(icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_oneOf_shouldSetOutlinePayloadIcon() throws {
        
        let icon = anyMessage()
        let source = oneOf(icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.icon, icon)
    }
    
    func test_parse_oneOf_shouldSetFirstFieldWithNilIcon() throws {
        
        let name = anyMessage()
        let source = oneOf(name: name, icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.firstField, .init(id: "_selected_service", title: "Услуга", value: name, icon: nil))
    }
    
    func test_parse_oneOf_shouldSetFirstField() throws {
        
        let name = anyMessage()
        let icon = anyMessage()
        let source = oneOf(name: name, icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.firstField, .init(id: "_selected_service", title: "Услуга", value: name, icon: .md5Hash(icon)))
    }
    
    func test_parse_oneOf_shouldDeliverOutput() throws {
        
        let product = makeOutlineProduct()
        let (puref, title, name, subtitle, icon) = (anyMessage(), anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let source = oneOf(name: name, puref: puref, title: title, subtitle: subtitle, icon: icon)
        let sut = makeSUT(outlineProduct: product)
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output, .init(
            outline: .init(
                amount: nil,
                product: product,
                fields: .init(),
                payload: .init(
                    puref: puref,
                    title: title,
                    subtitle: subtitle,
                    icon: icon
                )
            ),
            firstField: .init(
                id: "_selected_service",
                title: "Услуга",
                value: name,
                icon: .md5Hash(icon)
            )
        ))
    }
    
    // MARK: - picked
    
    func test_parse_picked_shouldDeliverOutlineProductErrorOnMissingOutlineProduct() throws {
        
        let sut = makeSUT(outlineProduct: nil)
        
        try XCTAssertThrowsError(sut.parse(source: picked())) {
            
            XCTAssertNoDiff($0 as? SUT.ParsingError, .missingProduct)
        }
    }
    
    func test_parse_picked_shouldSetOutlineAmountToNilOnNoAmountInQR() throws {
        
        let source = picked()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.amount)
    }
    
    func test_parse_picked_shouldSetOutlineAmountOnQRWithMapping() throws {
        
        let puref = anyMessage()
        let (qrCode, amount) = makeQRWithAmount()
        let qrMapping = makeAmountQRMapping(puref: puref)
        let source = picked(puref: puref, qrCode: qrCode, qrMapping: qrMapping)
        
        let output = try makeSUT().parse(source: source)
        
        try XCTAssertEqual(XCTUnwrap(output.outline.amount), amount, accuracy: 0.01)
    }
    
    func test_parse_picked_shouldSetOutlineProduct() throws {
        
        let product = makeOutlineProduct()
        let sut = makeSUT(outlineProduct: product)
        let source = picked()
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output.outline.product, product)
    }
    
    func test_parse_picked_shouldSetOutlineFieldsFromQRCodeAndMapping() throws {
        
        let puref = anyMessage()
        let (qrCode, _) = makeSampleQRCode()
        let source = picked(
            puref: puref,
            qrCode: qrCode,
            qrMapping: makeSampleQRMapping(puref: puref)
        )
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, [
            "GENERAL_FIRST_NAME": "John",
            "GENERAL_LAST_NAME": "Smith"
        ])
    }
    
    func test_parse_picked_shouldSetOutlinePayloadPuref() throws {
        
        let puref = anyMessage()
        let source = picked(puref: puref)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.puref, puref)
    }
    
    func test_parse_picked_shouldSetOutlinePayloadTitle() throws {
        
        let title = anyMessage()
        let source = picked(title: title)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.title, title)
    }
    
    func test_parse_picked_shouldSetNilOutlinePayloadSubtitle() throws {
        
        let source = picked()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_picked_shouldSetOutlinePayloadSubtitle() throws {
        
        let subtitle = anyMessage()
        let source = picked(inn: subtitle)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.subtitle, subtitle)
    }
    
    func test_parse_picked_shouldSetNilOutlinePayloadIconOnNil() throws {
        
        let source = picked(icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_picked_shouldSetOutlinePayloadIcon() throws {
        
        let icon = anyMessage()
        let source = picked(icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.icon, icon)
    }
    
    func test_parse_picked_shouldNotSetFirstFieldOnIsOfFalse() throws {
        
        let source = picked(isOneOf: false)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.firstField)
    }
    
    func test_parse_picked_shouldSetFirstFieldWithNilIconOnIsOneOfTrue() throws {
        
        let name = anyMessage()
        let source = picked(name: name, isOneOf: true, icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.firstField, .init(id: "_selected_service", title: "Услуга", value: name, icon: nil))
    }
    
    func test_parse_picked_shouldSetFirstFieldOnIsOneOfTrue() throws {
        
        let (name, icon) = (anyMessage(), anyMessage())
        let source = picked(name: name, isOneOf: true, icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.firstField, .init(id: "_selected_service", title: "Услуга", value: name, icon: .md5Hash(icon)))
    }
    
    // MARK: - single
    
    func test_parse_single_shouldDeliverOutlineProductErrorOnMissingOutlineProduct() throws {
        
        let sut = makeSUT(outlineProduct: nil)
        
        try XCTAssertThrowsError(sut.parse(source: single())) {
            
            XCTAssertNoDiff($0 as? SUT.ParsingError, .missingProduct)
        }
    }
    
    func test_parse_single_shouldSetOutlineAmountToNil() throws {
        
        let source = single()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.amount)
    }
    
    func test_parse_single_shouldSetOutlineProduct() throws {
        
        let product = makeOutlineProduct()
        let sut = makeSUT(outlineProduct: product)
        let source = single()
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output.outline.product, product)
    }
    
    func test_parse_single_shouldSetEmptyOutlineFields() throws {
        
        let source = single()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.fields, .init())
    }
    
    func test_parse_single_shouldSetOutlinePayloadPuref() throws {
        
        let puref = anyMessage()
        let source = single(puref: puref)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.puref, puref)
    }
    
    func test_parse_single_shouldSetOutlinePayloadTitle() throws {
        
        let title = anyMessage()
        let source = single(title: title)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.title, title)
    }
    
    func test_parse_single_shouldSetNilOutlinePayloadSubtitle() throws {
        
        let source = single()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_single_shouldSetNilOutlinePayloadIconOnNil() throws {
        
        let source = single(icon: nil)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.outline.payload.subtitle)
    }
    
    func test_parse_single_shouldSetOutlinePayloadIcon() throws {
        
        let icon = anyMessage()
        let source = single(icon: icon)
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNoDiff(output.outline.payload.icon, icon)
    }
    
    func test_parse_single_shouldSetFirstFieldToNil() throws {
        
        let source = single()
        
        let output = try makeSUT().parse(source: source)
        
        XCTAssertNil(output.firstField)
    }
    
    func test_parse_single_shouldDeliverOutput() throws {
        
        let product = makeOutlineProduct()
        let (name, puref, title, subtitle, icon) = (anyMessage(), anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let source = single(
            name: name, puref: puref, title: title, subtitle: subtitle, icon: icon
        )
        let sut = makeSUT(outlineProduct: product)
        
        let output = try sut.parse(source: source)
        
        XCTAssertNoDiff(output, .init(
            outline: .init(
                amount: nil,
                product: product,
                fields: .init(),
                payload: .init(
                    puref: puref,
                    title: title,
                    subtitle: subtitle,
                    icon: icon
                )
            ),
            firstField: nil
        ))
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
    
    private func oneOf(
        name: String = anyMessage(),
        puref: String = anyMessage(),
        id: String = anyMessage(),
        title: String = anyMessage(),
        subtitle: String? = nil,
        icon: String? = nil
    ) -> AnywayPaymentSourceParser.Source {
        
        return .oneOf(
            .init(name: name, puref: puref),
            .init(id: id, title: title, subtitle: subtitle, icon: icon)
        )
    }
    
    private func picked(
        name: String = anyMessage(),
        puref: String = anyMessage(),
        isOneOf: Bool = .random(),
        id: String = anyMessage(),
        icon: String? = nil,
        inn: String? = nil,
        title: String = anyMessage(),
        segment: String = anyMessage(),
        qrCode: QRCode = .init(original: "", rawData: [:]),
        qrMapping: QRMapping = .init(parameters: [], operators: [])
    ) -> AnywayPaymentSourceParser.Source {
        
        return .picked(
            .init(service: .init(name: name, puref: puref), isOneOf: isOneOf),
            .init(
                provider: .init(
                    origin: .init(
                        id: id,
                        icon: icon,
                        inn: inn,
                        title: title,
                        segment: segment
                    ),
                    segment: segment
                ),
                qrCode: qrCode,
                qrMapping: qrMapping
            )
        )
    }
    
    private func makeQRWithAmount(
        _ int: Int = .random(in: 1...100_000)
    ) -> (QRCode, Decimal) {
        
        let qrCode = QRCode(original: "", rawData: ["sum": "\(int)"])
        return (qrCode, Decimal(int)/100)
    }
    
    private func makeAmountQRMapping(
        puref: String
    ) -> QRMapping {
        
        let qrParameter = QRParameter(parameter: .general(.amount), keys: ["sum"], type: .double)
        
        return .init(
            parameters: [qrParameter],
            operators: [.init(operator: puref, parameters: [qrParameter])]
        )
    }
    
    private func makeSampleQRCode(
        _ int: Int = .random(in: 1...100_000)
    ) -> (QRCode, Decimal) {
        
        let qrCode = QRCode(original: "", rawData: [
            "first": "John",
            "last": "Smith"
        ])
        return (qrCode, Decimal(int)/100)
    }
    
    private func makeSampleQRMapping(
        puref: String
    ) -> QRMapping {
        
        let qrParameter1 = QRParameter(parameter: .general(.firstName), keys: ["first"], type: .string)
        let qrParameter2 = QRParameter(parameter: .general(.lastName), keys: ["last"], type: .string)
        
        return .init(
            parameters: [qrParameter1, qrParameter2],
            operators: [.init(
                operator: puref,
                parameters: [qrParameter1, qrParameter2]
            )]
        )
    }
    
    private func single(
        name: String = anyMessage(),
        puref: String = anyMessage(),
        id: String = anyMessage(),
        title: String = anyMessage(),
        subtitle: String? = nil,
        icon: String? = nil
    ) -> AnywayPaymentSourceParser.Source {
        
        return .single(
            .init(name: name, puref: puref),
            .init(id: id, title: title, subtitle: subtitle, icon: icon)
        )
    }
}

func anyAmount(
    _ value: Double = .random(in: 1...1_000)
) -> Decimal {
    
    return .init(value)
}
