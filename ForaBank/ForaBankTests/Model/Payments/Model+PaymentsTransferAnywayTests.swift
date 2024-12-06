//
//  Model+PaymentsTransferAnywayTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.06.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsTransferAnywayTests: XCTestCase {
    
    // MARK: - deliveryCurrency
    
    func test_deliveryCurrencyShouldReturnNilOnEmpty() {
        
        let data: [ParameterData] = []
        
        let deliveryCurrency = data.deliveryCurrency
        
        XCTAssertNoDiff(deliveryCurrency?.selectedCurrency, nil)
        XCTAssertNoDiff(deliveryCurrency?.currenciesList, nil)
    }
    
    func test_deliveryCurrency_shouldReturnNilOnDataThatDoesNotContainCurrencyIdentifier() {
        
        let data: [ParameterData] = [
            .test(id: "a")
        ]
        
        let deliveryCurrency = data.deliveryCurrency
        
        XCTAssertNoDiff(deliveryCurrency?.selectedCurrency, nil)
        XCTAssertNoDiff(deliveryCurrency?.currenciesList, nil)
        XCTAssertNil(data.countryDeliveryCurrency)
    }
    
    func test_deliveryCurrency_shouldReturnNilOnDataThatDoesNotContainCurrencyData() {
        
        let identifier = Payments.Parameter.Identifier.countryDeliveryCurrency
        let data: [ParameterData] = [
            .test(id: identifier.rawValue)
        ]
        
        let deliveryCurrency = data.deliveryCurrency
        
        XCTAssertNoDiff(deliveryCurrency?.selectedCurrency, nil)
        XCTAssertNoDiff(deliveryCurrency?.currenciesList, nil)
        XCTAssertNotNil(data.countryDeliveryCurrency)
    }
    
    func test_deliveryCurrency_shouldReturnValuesOnDataThatContainsCurrencyData() {
        
        let identifier = Payments.Parameter.Identifier.countryDeliveryCurrency
        let data: [ParameterData] = [
            .test(dataType: "=;RUB=USD,EUR; USD=RUB,EUR", id: identifier.rawValue)
        ]
        
        let deliveryCurrency = data.deliveryCurrency
        
        XCTAssertNoDiff(deliveryCurrency?.selectedCurrency, .rub)
        XCTAssertNoDiff(deliveryCurrency?.currenciesList, [.rub, .usd])
        XCTAssertNotNil(data.countryDeliveryCurrency)
    }
}

private extension Array where Element == ParameterData {
    
    var countryDeliveryCurrency: Element? {
        
        first(where: { $0.id == Payments.Parameter.Identifier.countryDeliveryCurrency.rawValue })
    }
}

extension ParameterData {
    
    static func test(
        content: String? = nil,
        dataType: String? = nil,
        id: String,
        isPrint: Bool? = nil,
        isRequired: Bool? = nil,
        mask: String? = nil,
        maxLength: Int? = nil,
        minLength: Int? = nil,
        order: Int? = nil,
        rawLength: Int = 0,
        readOnly: Bool? = nil,
        regExp: String? = nil,
        subTitle: String? = nil,
        title: String = "Title",
        type: String? = nil,
        inputFieldType: inputFieldType? = nil,
        dataDictionary: String? = nil,
        dataDictionaryРarent: String? = nil,
        group: String? = nil,
        subGroup: String? = nil,
        inputMask: String? = nil,
        phoneBook: Bool? = nil,
        svgImage: SVGImageData? = nil,
        viewType: ViewType = .input
    ) -> Self {
        
        .init(
            content: content,
            dataType: dataType,
            id: id,
            isPrint: isPrint,
            isRequired: isRequired,
            mask: mask,
            maxLength: maxLength,
            minLength: minLength,
            order: order,
            rawLength: rawLength,
            readOnly: readOnly,
            regExp: regExp,
            subTitle: subTitle,
            title: title,
            type: type,
            inputFieldType: inputFieldType,
            dataDictionary: dataDictionary,
            dataDictionaryРarent: dataDictionaryРarent,
            group: group,
            subGroup: subGroup,
            inputMask: inputMask,
            phoneBook: phoneBook,
            svgImage: svgImage,
            viewType: viewType
        )
    }
}
