//
//  RemoteStepAbroadParametersMapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.08.2023.
//

@testable import ForaBank
import XCTest

final class RemoteStepAbroadParametersMapperTests: XCTestCase {
    
    // MARK: Selected Operators
    
    func test_map_shouldDeliverEmptyOnEmptyResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let response = makeResponse()
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertTrue(parameters.isEmpty)
        }
    }
    
    func test_map_shouldDeliverCountryPayeeOnPayeeNameInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let response = makeResponse(payeeName: "Payee Name")
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldNotDeliverAmountOnMissingCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let response = makeResponse(
                amount: 12_345,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverAmountWithNilValueOnNilNormalAmountFormattingOnAmountWithCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let response = makeResponse(
                amount: 12_345,
                currencyPayer: .amd,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator, normalAmountFormatted: { _,_ in nil })
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: nil),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverAmountOnAmountWithCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let response = makeResponse(
                amount: 12_345,
                currencyPayer: .rub,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: "12345.0 RUB"),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    // MARK: Non-Selected Operators
    
    func test_map_shouldDeliverEmptyOnEmptyResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse()
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertTrue(parameters.isEmpty)
        }
    }
    
    func test_map_shouldDeliverCountryPayeeOnPayeeNameInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse(payeeName: "Payee Name")
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
        }
    }
    
    func test_map_shouldNotDeliverAmountOnMissingCurrencyPayerInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse(
                amount: 12_345,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
        }
    }
    
    func test_map_shouldNotDeliverAmountOnAmountWithCurrencyPayerInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse(
                amount: 12_345,
                currencyPayer: .amd,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverAmountWithNilValueOnNilNornalAmountFormattingOnCreditAmountWithCurrencyPayeeInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse(
                creditAmount: 12_345,
                currencyPayee: .amd,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator, normalAmountFormatted: { _,_ in nil })
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: nil),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryPayeeAmount", value: nil),
                    icon: .local("ic24User"),
                    title: "Сумма зачисления в валюте",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverAmountOnCreditAmountWithCurrencyPayeeInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let response = makeResponse(
                creditAmount: 12_345,
                currencyPayee: .rub,
                payeeName: "Payee Name"
            )
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: "12345.0 RUB"),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryPayeeAmount", value: "12345.0 RUB"),
                    icon: .local("ic24User"),
                    title: "Сумма зачисления в валюте",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    // MARK: - All Payments Operators
    
    func test_map_shouldNotDeliverOfertaOnBadURL() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let fieldValue = " "
            let response = makeResponseWithAdditional([
                .dummy(fieldName: "oferta", fieldValue: fieldValue)
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNil(URL(string: fieldValue))
            XCTAssertNoDiff(parameters.checkParameters, [])
        }
    }
    
    func test_map_shouldNotDeliverOfertaOnMissingFieldTitle() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponseWithAdditional([
                .dummy(fieldName: "oferta", fieldValue: "abc")
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.checkParameters, [])
        }
    }
    
    
    func test_map_shouldDeliverOferta() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponseWithAdditional([
                .dummy(
                    fieldName: "oferta",
                    fieldTitle: "С <u>офертой</u> ознакомлен.",
                    fieldValue: "abc"
                )
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.checkParameters, [
                .init(
                    .init(id: "countryOferta", value: "true"),
                    title: "С <u>офертой</u> ознакомлен.",
                    urlString: "abc",
                    style: .c2bSubscription,
                    mode: .abroad,
                    group: nil
                )
            ])
        }
    }
    
    func test_map_shouldDeliverDividendOnDividend() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponseWithAdditional([
                .dummy(
                    fieldName: "dividend",
                    fieldTitle: "источником перевода не являются средства",
                    typeIdParameterList: "checkbox"
                )
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.checkParameters, [
                .init(
                    .init(id: "countryDividend", value: "true"),
                    title: "источником перевода не являются средства",
                    urlString: nil,
                    style: .c2bSubscription,
                    mode: .normal,
                    group: nil
                )
            ])
        }
    }
    
    func test_map_shouldNotDeliverAmountOnNilFormattedAmount() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponse(debitAmount: 12_345)
            
            let parameters = map(response, with: paymentsOperator, formattedAmount: { _ in nil })
            
            XCTAssertNoDiff(parameters.infoParameters, [])
        }
    }
    
    func test_map_shouldDeliverAmount() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponse(debitAmount: 12_345)
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "SumSTrs", value: "12345.0"),
                    icon: .local("ic24Coins"),
                    title: "Сумма списания",
                    lineLimit: nil,
                    placement: .feed,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverCountryTransferNumberWithNilValue() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponseWithAdditional([
                .dummy(fieldName: "trnReference")
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryTransferNumber", value: nil),
                    icon: .local("ic24PercentCommission"),
                    title: "Номер перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverCountryTransferNumber() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponseWithAdditional([
                .dummy(fieldName: "trnReference", fieldValue: "abc")
            ])
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "countryTransferNumber", value: "abc"),
                    icon: .local("ic24PercentCommission"),
                    title: "Номер перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldNotDeliverFeeOnNilFormattedAmount() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponse(fee: 321)
            
            let parameters = map(response, with: paymentsOperator, formattedAmount: { _ in nil })
            
            XCTAssertNoDiff(parameters.infoParameters, [])
        }
    }
    
    func test_map_shouldDeliverFeeOnFee() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponse(fee: 321)
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.infoParameters, [
                .init(
                    .init(id: "ru.forabank.sense.fee", value: "321.0"),
                    icon: .local("ic24PercentCommission"),
                    title: "Комиссия",
                    lineLimit: nil,
                    placement: .feed,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
        }
    }
    
    func test_map_shouldDeliverParameterCodeOnOTP() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let response = makeResponse(needOTP: true)
            
            let parameters = map(response, with: paymentsOperator)
            
            XCTAssertNoDiff(parameters.codeParameters.map(\.equatableView), [
                .init(
                    parameter: .init(
                        id: "ru.forabank.sense.code",
                        value: nil
                    ),
                    title: "Введите код из СМС",
                    limit: 6,
                    timerDelay: 60.0,
                    errorMessage: "Код введен неправильно",
                    placement: .feed,
                    group: nil
                )
            ])
        }
    }
    
    // MARK: - Helpers
    
    private func map(
        _ response: TransferResponseData,
        with paymentsOperator: Payments.Operator,
        formattedAmount: @escaping (Double) -> String? = { "\($0)" },
        normalAmountFormatted: @escaping (Double, String) -> String? = { "\($0) \($1)" }
    ) -> [PaymentsParameterRepresentable] {
        
        return RemoteStepAbroadParametersMapper.map(
            response,
            paymentsOperator: paymentsOperator,
            formattedAmount: formattedAmount,
            normalAmountFormatted: normalAmountFormatted
        )
    }
    
    private func makeResponseWithAdditional(
        _ additionalList: [TransferAnywayResponseData.AdditionalData]
    ) -> TransferAnywayResponseData {
        
        .makeDummy(
            additionalList: additionalList,
            finalStep: true
        )
    }
    
    private func makeResponse(
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
        documentStatus: TransferResponseBaseData.DocumentStatus? = nil,
        paymentOperationDetailId: Int = 1
    ) -> TransferResponseData {
        
        .init(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee,
            needMake: needMake,
            needOTP: needOTP,
            payeeName: payeeName,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId,
            scenario: .ok
        )
    }
    
    private let allPaymentsOperators: [Payments.Operator] = Payments.Operator.allCases
    
    private let abroadPaymentsOperators: [Payments.Operator] = [
        .direct, .cardKZ, .cardTJ, .cardUZ, .cardHumoUZ
    ]
    
    private var nonAbroadPaymentsOperators: [Payments.Operator] {
        
        allPaymentsOperators.filter {
            !abroadPaymentsOperators.contains($0)
        }
    }
}

// MARK: - Helpers

private extension Array where Element == PaymentsParameterRepresentable {
    
    var infoParameters: [Payments.ParameterInfo] {
        
        compactMap { $0 as? Payments.ParameterInfo }
    }
    
    var checkParameters: [Payments.ParameterCheck] {
        
        compactMap { $0 as? Payments.ParameterCheck }
    }
    
    var codeParameters: [Payments.ParameterCode] {
        
        compactMap { $0 as? Payments.ParameterCode }
    }
}
