//
//  Model+AbroadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.08.2023.
//

@testable import ForaBank
import XCTest

final class Model_AbroadTests: XCTestCase {
    
    func test_paymentsProcessRemoteStepAbroad_shouldReturnEmptyOnEmpty() async throws {
        
        let operation: Payments.Operation = .makeDummy()
        let response: TransferResponseData = .makeDummy()
        let model: Model = .mockWithEmptyExcept()
        
        let step = try await model.paymentsProcessRemoteStepAbroad(
            operation: operation,
            response: response
        )
        
        XCTAssertTrue(operation.parameters.isEmpty)
        XCTAssertTrue(step.parameters.isEmpty)
        XCTAssertNoDiff(step.front, .empty(isCompleted: false))
        XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
    }
    
    // MARK: Selected Operators
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverEmptyOnEmptyResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy()
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, ["countryDropDownList"])
            XCTAssertTrue(step.parameters.isEmpty)
            XCTAssertNoDiff(step.front, .empty(isCompleted: false))
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverCountryPayeeOnPayeeNameInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverAmountOnMissingCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                amount: 12_345,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverAmountWithNilValueOnMissingCurrencyOnAmountWithCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                amount: 12_345,
                currencyPayer: .amd,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
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
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee", "countryCurrencyAmount"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverAmountOnAmountWithCurrencyPayerInResponseForSelectedOperators() async throws {
        
        for paymentsOperator in abroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                amount: 12_345,
                currencyPayer: .rub,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: "12 345 ₽"),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee", "countryCurrencyAmount"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    // MARK: Non-Selected Operators
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverEmptyOnEmptyResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy()
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, ["countryDropDownList"])
            XCTAssertTrue(step.parameters.isEmpty)
            XCTAssertNoDiff(step.front, .empty(isCompleted: false))
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverCountryPayeeOnPayeeNameInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverAmountOnMissingCurrencyPayerInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                amount: 12_345,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverAmountOnAmountWithCurrencyPayerInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                amount: 12_345,
                currencyPayer: .amd,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
            ])
            XCTAssertNoDiff(step.parameters.map(\.value), ["Payee Name"])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: ["countryPayee"],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverAmountWithNilValueOnMissingCurrencyOnCreditAmountWithCurrencyPayeeInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                creditAmount: 12_345,
                currencyPayee: .amd,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
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
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryPayee",
                        "countryCurrencyAmount",
                        "countryPayeeAmount"
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverAmountOnCreditAmountWithCurrencyPayeeInResponseForNonSelectedOperators() async throws {
        
        for paymentsOperator in nonAbroadPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                creditAmount: 12_345,
                currencyPayee: .rub,
                payeeName: "Payee Name"
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryPayee", value: "Payee Name"),
                    icon: .local("ic24User"),
                    title: "Получатель",
                    lineLimit: nil,
                    group: nil
                ),
                .init(
                    .init(id: "countryCurrencyAmount", value: "12 345 ₽"),
                    icon: .local("ic24Coins"),
                    title: "Сумма перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
                .init(
                    .init(id: "countryPayeeAmount", value: "12 345 ₽"),
                    icon: .local("ic24User"),
                    title: "Сумма зачисления в валюте",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryPayee",
                        "countryCurrencyAmount",
                        "countryPayeeAmount"
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    // MARK: - All Payments Operators
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverOfertaOnBadURL() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let fieldValue = " "
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(fieldName: "oferta", fieldValue: fieldValue)
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNil(URL(string: fieldValue))
            XCTAssertNoDiff(step.parameters.count, step.checkParameters.count)
            XCTAssertNoDiff(step.checkParameters, [
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverOfertaOnMissingFieldTitle() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(fieldName: "oferta", fieldValue: "abc")
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.checkParameters.count)
            XCTAssertNoDiff(step.checkParameters, [])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverOferta() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(
                        fieldName: "oferta",
                        fieldTitle: "С <u>офертой</u> ознакомлен.",
                        fieldValue: "abc"
                    )
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.checkParameters.count)
            XCTAssertNoDiff(step.checkParameters, [
                .init(
                    .init(id: "countryOferta", value: "true"),
                    title: "С <u>офертой</u> ознакомлен.",
                    urlString: "abc",
                    style: .c2bSubscription,
                    mode: .abroad,
                    group: nil
                )
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryOferta",
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverDividend() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(
                        fieldName: "dividend",
                        fieldTitle: "источником перевода не являются средства",
                        typeIdParameterList: "checkbox"
                    )
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.checkParameters.count)
            XCTAssertNoDiff(step.checkParameters, [
                .init(
                    .init(id: "countryDividend", value: "true"),
                    title: "источником перевода не являются средства",
                    urlString: nil,
                    style: .c2bSubscription,
                    mode: .normal,
                    group: nil
                )
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryDividend",
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(
                step.back,
                .init(stage: .remote(.next), required: ["countryDividend"], processed: nil)
            )
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverAmountOnMissingProduct() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                debitAmount: 12_345
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertTrue(model.products.value.isEmpty)
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList",
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverAmount() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let products = makeProductsData([(.card, 1)])
            let product = try XCTUnwrap(products.flatMap(\.value).first)
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator,
                product: product
            )
            let response: TransferResponseData = .makeDummy(
                debitAmount: 12_345
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            model.products.value = products
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertFalse(model.products.value.isEmpty)
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList",
                "ru.forabank.sense.product"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "SumSTrs", value: "12 345 ₽"),
                    icon: .local("ic24Coins"),
                    title: "Сумма списания",
                    lineLimit: nil,
                    placement: .feed,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "SumSTrs"
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverCountryTransferNumberWithNilValue() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(fieldName: "trnReference")
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryTransferNumber", value: nil),
                    icon: .local("ic24PercentCommission"),
                    title: "Номер перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryTransferNumber",
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverCountryTransferNumber() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferAnywayResponseData = .makeDummy(
                additionalList: [
                    .dummy(fieldName: "trnReference", fieldValue: "abc")
                ],
                finalStep: false
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "countryTransferNumber", value: "abc"),
                    icon: .local("ic24PercentCommission"),
                    title: "Номер перевода",
                    lineLimit: nil,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "countryTransferNumber",
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldNotDeliverFeeOnMissingProduct() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                fee: 321
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertTrue(model.products.value.isEmpty)
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverFeeOnFee() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let products = makeProductsData([(.card, 1)])
            let product = try XCTUnwrap(products.flatMap(\.value).first)
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator,
                product: product
            )
            let response: TransferResponseData = .makeDummy(
                fee: 321
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            model.products.value = products
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertFalse(model.products.value.isEmpty)
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList",
                "ru.forabank.sense.product"
            ])
            XCTAssertNoDiff(step.parameters.count, step.infoParameters.count)
            XCTAssertNoDiff(step.infoParameters, [
                .init(
                    .init(id: "ru.forabank.sense.fee", value: "321 ₽"),
                    icon: .local("ic24PercentCommission"),
                    title: "Комиссия",
                    lineLimit: nil,
                    placement: .feed,
                    group: .init(id: "confirm", type: .info)
                ),
            ])
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "ru.forabank.sense.fee"
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.next)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldDeliverParameterCodeOnOTP() async throws {
        
        for paymentsOperator in allPaymentsOperators {
            
            let operation = operationWithCountryDropDownList(
                paymentsOperator: paymentsOperator
            )
            let response: TransferResponseData = .makeDummy(
                needOTP: true
            )
            let model: Model = .mockWithEmptyExcept()
            model.currencyList.value = [.rub]
            
            let step = try await model.paymentsProcessRemoteStepAbroad(
                operation: operation,
                response: response
            )
            
            XCTAssertNoDiff(operation.parametersIds, [
                "countryDropDownList",
            ])
            XCTAssertNoDiff(step.parameters.count, step.codeParameters.count)
            XCTAssertNoDiff(step.codeParameters.map(\.equatableView), [
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
            XCTAssertNoDiff(
                step.front,
                .init(
                    visible: [
                        "ru.forabank.sense.code"
                    ],
                    isCompleted: false
                )
            )
            XCTAssertNoDiff(step.back, .empty(stage: .remote(.confirm)))
        }
    }
    
    func test_paymentsProcessRemoteStepAbroad_shouldReturnAntifraudParameter() async throws {
       
        let operation = operationWithCountryDropDownList(
            paymentsOperator: .contact
        )
        let response: TransferResponseData = .makeDummy(
            needOTP: true,
            scenario: .suspect
        )
        let model: Model = .mockWithEmptyExcept()
        
        let step = try await model.paymentsProcessRemoteStepAbroad(
            operation: operation,
            response: response
        )
        
        XCTAssertTrue(step.parametersIds.contains(where: { $0 == "AFResponse" }))
    }
    
    // MARK: - Helpers
    
    private func operationWithCountryDropDownList(
        paymentsOperator: Payments.Operator,
        product: ProductData? = nil
    ) -> Payments.Operation {
        
        let identifier: Payments.Parameter.Identifier = .countryDropDownList
        let countryDropDownList = Payments.ParameterSelectDropDownList(
            .init(
                id: identifier.rawValue,
                value: paymentsOperator.rawValue
            ),
            title: "any title",
            options: []
        )
        
        let product: Payments.ParameterProduct? = product.map {
            .init(
                value: "\($0.id)",
                filter: .generalFrom,
                isEditable: true
            )
        }
        
        let parameters: [PaymentsParameterRepresentable?] = [
            countryDropDownList,
            product
        ]
        
        return .makeDummy(with: parameters.compactMap { $0 })
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

extension Payments.Operation {
    
    static func makeDummy(
        with parameters: [PaymentsParameterRepresentable] = []
    ) -> Self {
        
        let step: Payments.Operation.Step = .init(
            parameters: parameters,
            front: .empty(),
            back: .empty()
        )
        
        return .init(
            service: .transport,
            source: nil,
            steps: [step],
            visible: []
        )
    }
}

// MARK: - Helpers

private extension Payments.Operation.Step {
    
    var infoParameters: [Payments.ParameterInfo] {
        
        parameters.compactMap { $0 as? Payments.ParameterInfo }
    }
    
    var checkParameters: [Payments.ParameterCheck] {
        
        parameters.compactMap { $0 as? Payments.ParameterCheck }
    }
    
    var codeParameters: [Payments.ParameterCode] {
        
        parameters.compactMap { $0 as? Payments.ParameterCode }
    }
}

extension TransferAnywayResponseData.AdditionalData {
    
    static func dummy(
        fieldName: String,
        fieldTitle: String? = nil,
        fieldValue: String? = nil,
        svgImage: SVGImageData? = nil,
        typeIdParameterList: String? = nil,
        recycle: Bool? = nil
    ) -> Self {
        
        .init(
            fieldName: fieldName,
            fieldTitle: fieldTitle,
            fieldValue: fieldValue,
            svgImage: svgImage,
            typeIdParameterList: typeIdParameterList,
            recycle: recycle
        )
    }
}

extension Payments.ParameterCode {
    
    var equatableView: EquatableView {
        
        .init(
            parameter: parameter,
            title: title,
            limit: limit,
            timerDelay: timerDelay,
            errorMessage: errorMessage,
            placement: placement,
            group: group
        )
    }
    
    struct EquatableView: Equatable {
        
        let parameter: Payments.Parameter
        let title: String
        let limit: Int?
        let timerDelay: TimeInterval
        let errorMessage: String
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
    }
}
