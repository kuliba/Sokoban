//
//  Model+PaymentsAbroadTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 30.05.2023.
//

import XCTest
@testable import ForaBank

final class Model_PaymentsAbroadTests: XCTestCase {

    func test_paymentsTransferAbroadStepParameter_emptyResult() async throws {
        
        // given
        let sut = makeSut()
        
        // when
        let operation = Payments.Operation.makeEmpty()
        let response = TransferAnywayResponseData.make()
        let result = try await sut.paymentsTransferAbroadStepParameters(operation, response: response)
        
        // then
        XCTAssertTrue(result.isEmpty)
    }
    
        // MARK: - test abroadAmountParameter
    
    func test_abroadAmountParameter_shouldReturnAmountZero() {
        
        // given
        let sut = makeSut()
        
        // when
        let result = sut.abroadAmountParameter(
            "RUB",
            .rub,
            [.rub],
            100)
        
        // then
        XCTAssertNoDiff(result.amount, 0)
    }
}

//MARK: Process Tests
extension Model_PaymentsAbroadTests {
    
    func test_paymentsTransferAnywayAbroadAdditional_shouldReturnEmptyResult() async throws {
        
        // given
        let sut = makeSut()
        let parameters: [PaymentsParameterRepresentable] = [Payments.ParameterHeader(title: "")]
        
        // when
        let result = try sut.paymentsTransferAnywayAbroadAdditional(
            parameters,
            restrictedParameters: [
                Payments.Parameter.Identifier.header.rawValue
            ])
        
        // then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_paymentsTransferAnywayAbroadAdditional_parametersWithSurName_shouldReturnAdditionalData() async throws {
        
        // given
        let sut = makeSut(currencyList: [.rub])
        let parameters: [PaymentsParameterRepresentable] = .mock(bSurName: "bSurName")
        
        
        // when
        let result = try sut.paymentsTransferAnywayAbroadAdditional(
            parameters,
            restrictedParameters: [
                Payments.Parameter.Identifier.header.rawValue
            ])
        
        // then
        XCTAssertNoDiff(
            result,
            [
                .init(
                    fieldid: 3,
                    fieldname: "CURR",
                    fieldvalue: "RUB"
                ),
                .init(
                    fieldid: 4,
                    fieldname: "bSurName",
                    fieldvalue: "bSurName"
                ),
                .init(
                    fieldid: 6,
                    fieldname: "ID",
                    fieldvalue: "value"
                )
            ]
        )
    }
    
    func test_paymentsTransferAnywayAbroadAdditional_shouldReturnAdditionalData() async throws {
        
        // given
        let sut = makeSut()
        let parameters: [PaymentsParameterRepresentable] = .mock()
        
        
        // when
        let result = try sut.paymentsTransferAnywayAbroadAdditional(
            parameters,
            restrictedParameters: [
                Payments.Parameter.Identifier.header.rawValue
            ])
        
        // then
        XCTAssertNoDiff(
            result,
            [
                .init(
                    fieldid: 4,
                    fieldname: "bSurName",
                    fieldvalue: ""
                ),
                .init(
                    fieldid: 6,
                    fieldname: "ID",
                    fieldvalue: "value"
                )
            ]
        )
    }
}

//MARK: RestrictedParametersAbroad computed property tests

extension Model_PaymentsAbroadTests {
    
    func test_model_restrictedParametersAbroad_shouldReturnIdentifiers() async throws {
        
        // given
        let sut = makeSut()
        
        let count = sut.restrictedParametersAbroad.count
        // then
        XCTAssertEqual(count, 10)
        XCTAssertNoDiff(
            sut.restrictedParametersAbroad,
            [
                "ru.forabank.sense.code",
                "ru.forabank.sense.product",
                "ru.forabank.sense.continue",
                "ru.forabank.sense.header",
                "ru.forabank.sense.operator",
                "ru.forabank.sense.service",
                "ru.forabank.sense.category",
                "countryDropDownList",
                "countryCurrencyFilter",
                "paymentSystem"
            ])
    }
}

private extension [PaymentsParameterRepresentable] {
    
    static func mock(bSurName: Payments.Parameter.Value = nil) -> [PaymentsParameterRepresentable] {
        
        [
            Payments.ParameterHeader(title: ""),
            Payments.ParameterMock(id: "search#3#"),
            Payments.ParameterMock(id: "search#5#"),
            Payments.ParameterMock(id: "CURR", value: "RUB"),
            Payments.ParameterMock(id: "bSurName", value: bSurName),
            Payments.ParameterAmount(
                value: "1",
                title: "parameterAmountTitle",
                currencySymbol: "₽",
                deliveryCurrency: .init(
                    selectedCurrency: .rub,
                    currenciesList: [.rub]
                ),
                validator: .init(
                    minAmount: 1,
                    maxAmount: 10
                )),
            Payments.ParameterMock(id: "ID", value: "value")
        ]
    }
}

private extension Model_PaymentsAbroadTests {
    
    func makeSut(currencyList: [CurrencyData] = []) -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        model.currencyList.value = currencyList
        
        return model
    }
}

private extension Payments.Operation {
    
    static func makeEmpty() -> Payments.Operation {
        
        .init(service: .abroad)
    }
}

private extension TransferAnywayResponseData {
    
    static func make(
        amount: Double? = nil,
        creditAmount: Double? = nil,
        currencyAmount: Currency? = nil,
        currencyPayee: Currency? = nil,
        currencyPayer: Currency? = nil,
        currencyRate: Double? = nil,
        debitAmount: Double? = nil,
        fee: Double? = nil,
        needMake: Bool? = nil,
        needOTP: Bool? = nil,
        payeeName: String? = nil,
        documentStatus: DocumentStatus? = nil,
        paymentOperationDetailId: Int = 0,
        additionalList: [AdditionalData] = [],
        finalStep: Bool = false,
        infoMessage: String? = nil,
        needSum: Bool = false,
        printFormType: String? = nil,
        parameterListForNextStep: [ParameterData] = []) -> TransferAnywayResponseData {
            
            .init(amount: amount, creditAmount: creditAmount, currencyAmount: currencyAmount, currencyPayee: currencyPayee, currencyPayer: currencyPayer, currencyRate: currencyRate, debitAmount: debitAmount, fee: fee, needMake: needMake, needOTP: needOTP, payeeName: payeeName, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId, additionalList: additionalList, finalStep: finalStep, infoMessage: infoMessage, needSum: needSum, printFormType: printFormType, parameterListForNextStep: parameterListForNextStep, scenario: .ok)
        }
}
