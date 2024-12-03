//
//  ResponseMapper+mapGetCollateralLandingResponseTests.swift.swift
//
//
//  Created by Valentin Ozerov on 29.11.2024.
//

import RemoteServices
import XCTest
import CollateralLoanLandingGetCollateralLandingBackend

final class ResponseMapper_mapGetCollateralLandingResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = Data()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_shouldDeliverInvalidOnOkHTTPURLResponseStatusCodeWithNoData() throws {
        
        let invalidData = Data(jsonStringWithEmpty.utf8)
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: invalidData)))
    }
    
    func test_map_shouldGetValidProductName() throws {
        
        let data = Data(validJson.utf8)
        let result = try map(data).get()
        
        XCTAssertEqual(result.list.count, 1)
        XCTAssert(result.list.first?.name == "Кредит под залог недвижимости" )
    }
    
    func test_map_shouldBeInvalidWithoutSerial() throws {
        
        let invalidData = Data(noSerialJson.utf8)
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldBeInvalidWithoutProducts() throws {
        
        let invalidData = Data(noProductsJson.utf8)
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldBeInvalidWithoutTheme() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            theme: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutName() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            name: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutMarketing() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            marketing: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutConditions() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            conditions: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    conditions: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    conditions: [.stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    conditions: [.stub(), .stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutCalc() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutFrequentlyAskedQuestions() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            frequentlyAskedQuestions: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyFrequentlyAskedQuestions() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    frequentlyAskedQuestions: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneFrequentlyAskedQuestion() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    frequentlyAskedQuestions: [.stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoFrequentlyAskedQuestion() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    frequentlyAskedQuestions: [.stub(), .stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutDocuments() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            documents: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyDocuments() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    documents: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneDocument() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    documents: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoDocuments() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    documents: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutConsents() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            consents: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyConsents() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    consents: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneConsent() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    consents: [.stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoConsent() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    consents: [.stub(), .stub()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutCities() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            cities: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyCities() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    cities: []
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeValidWithOneCity() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    cities: [anyMessage()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeValidWithTwoCity() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    cities: [anyMessage(), anyMessage()]
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeInvalidWithoutIcons() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: nil
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutMarketingLabelTag() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            marketing: .stub(
                labelTag: nil
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutMarketingImage() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            marketing: .stub(
                image: nil
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutMarketingParams() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            marketing: .stub(params: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    marketing: .stub(params: [])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeValidWithOneMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    marketing: .stub(params: [anyMessage()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeValidWithTwoMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    marketing: .stub(params: [anyMessage(), anyMessage()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeInvalidWithoutConditionIcon() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            conditions: [
                .stub(icon: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutConditionTitle() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            conditions: [
                .stub(title: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutConditionSubtitle() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            conditions: [
                .stub(subTitle: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcAmount() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(amount: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcCollateral() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(collateral: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(collateral: [])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(collateral: [.stub()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(collateral: [.stub(), .stub()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutCalcRates() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(rates: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithEmptyCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(rates: [])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithOneCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(rates: [.stub()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeValidWithTwoCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    calc: .stub(rates: [.stub(), .stub()])
                )
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeInvalidWithoutCalcAmountMinIntValue() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                amount: .stub(minIntValue: nil)
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcAmountMaxIntValue() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                amount: .stub(maxIntValue: nil)
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcAmountMaxStringValue() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                amount: .stub(maxStringValue: nil)
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcCollateralIcon() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                collateral: [
                    .stub(icon: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcCollateralName() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                collateral: [
                    .stub(name: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcCollateralType() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                collateral: [
                    .stub(type: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcRateRateBase() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                rates: [
                    .stub(rateBase: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcRateRatePayrollClient() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                rates: [
                    .stub(ratePayrollClient: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcRateTermMonth() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                rates: [
                    .stub(termMonth: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutCalcRateTermStringValue() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            calc: .stub(
                rates: [
                    .stub(termStringValue: nil)
                ]
            )
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutFrequentlyAskedQuestionQuestion() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            frequentlyAskedQuestions: [
                .stub(question: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutFrequentlyAskedQuestionAnswer() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            frequentlyAskedQuestions: [
                .stub(answer: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutDocumentTitle() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            documents: [
                .stub(title: nil)
            ]
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeValidWithoutDocumentIcon() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    documents: [
                        .stub(icon: nil)
                    ]
                )
            ]))
        
        let validData = try stub.encoded()
        
        XCTAssertNoThrow(try map(validData).get())
    }
    
    func test_map_shouldBeValidWithoutDocumentLink() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    documents: [
                        .stub(link: nil)
                    ]
                )
            ]))
        
        let validData = try stub.encoded()
        
        XCTAssertNoThrow(try map(validData).get())
    }

    func test_map_shouldBeValidWithoutConsentName() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    consents: [
                        .stub(name: nil)
                    ]
                )
            ]))
        
        let validData = try stub.encoded()
        
        XCTAssertNoThrow(try map(validData).get())
    }

    func test_map_shouldBeValidWithoutConsentLink() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(
                    consents: [
                        .stub(link: nil)
                    ]
                )
            ]))
        
        let validData = try stub.encoded()
        
        XCTAssertNoThrow(try map(validData).get())
    }

    func test_map_shouldBeInvalidWithoutIconsProductName() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: .stub(productName: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutIconsAmount() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: .stub(amount: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutIconsTerm() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: .stub(term: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutIconsRate() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: .stub(rate: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    func test_map_shouldBeInvalidWithoutIconsCity() throws {
        
        let invalidData = try CollateralLandingStubProduct.stub(
            icons: .stub(city: nil)
        ).encoded()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }

    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.MappingResult<ResponseMapper.GetCollateralLandingResponse>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> Response {
        
        ResponseMapper.mapCreateGetCollateralLandingResponse(data, httpURLResponse)
    }
}

struct CodableResponse: Encodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: SerialStamped
    
    struct SerialStamped: Encodable {
        
        let serial: String
        let products: [CollateralLandingStubProduct]
    }
    
    func encoded() throws -> Data {
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        
        return jsonData
    }
}

struct CollateralLandingStubProduct: Encodable {
    
    let theme: Theme?
    let name: String?
    let marketing: Marketing?
    let conditions: [Condition]?
    let calc: Calc?
    let frequentlyAskedQuestions: [FrequentlyAskedQuestion]?
    let documents: [Document]?
    let consents: [Consent]?
    let cities: [String]?
    let icons: Icons?
    
    enum Theme: String, Encodable {
        
        case gray
        case white
        case unknown
    }
    
    struct Marketing: Encodable {
        
        let labelTag: String?
        let image: String?
        let params: [String]?
    }
    
    struct Condition: Encodable {
        
        let icon: String?
        let title: String?
        let subTitle: String?
    }
    
    struct Calc: Encodable {
        
        let amount: Amount?
        let collateral: [Collateral]?
        let rates: [Rate]?
        
        struct Amount: Encodable {
            
            let minIntValue: UInt?
            let maxIntValue: UInt?
            let maxStringValue: String?
        }
        
        struct Collateral: Encodable {
            
            let icon: String?
            let name: String?
            let type: String?
        }
        
        struct Rate: Encodable {
            
            let rateBase: Double?
            let ratePayrollClient: Double?
            let termMonth: UInt?
            let termStringValue: String?
        }
    }
    
    struct FrequentlyAskedQuestion: Encodable {
        
        let question: String?
        let answer: String?
    }
    
    struct Document: Encodable {
        
        let title: String?
        let icon: String?
        let link: String?
    }
    
    struct Consent: Encodable {
        
        let name: String?
        let link: String?
    }
    
    struct Icons: Encodable {
        
        let productName: String?
        let amount: String?
        let term: String?
        let rate: String?
        let city: String?
    }
}

extension CollateralLandingStubProduct {
    
    static func stub(
        theme: Theme? = .stub(),
        name: String? = anyMessage(),
        marketing: Marketing? = .stub(),
        conditions: [Condition]? = [.stub()],
        calc: Calc? = .stub(),
        frequentlyAskedQuestions: [FrequentlyAskedQuestion]? = [.stub()],
        documents: [Document]? = [.stub()],
        consents: [Consent]? = [.stub()],
        cities: [String]? = [anyMessage()],
        icons: Icons? = .stub()
    ) -> Self {
        Self(
            theme: theme,
            name: name,
            marketing: marketing,
            conditions: conditions,
            calc: calc,
            frequentlyAskedQuestions: frequentlyAskedQuestions,
            documents: documents,
            consents: consents,
            cities: cities,
            icons: icons
        )
    }
    
    func encoded() throws -> Data {
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        
        return jsonData
    }
}

extension CollateralLandingStubProduct.Theme {
    
    static func stub() -> Self {
        
        [.gray, .white, .unknown].randomElement() ?? .unknown
    }
}

extension CollateralLandingStubProduct.Marketing {
    
    static func stub(
        labelTag: String? = anyMessage(),
        image: String? = anyMessage(),
        params: [String]? = [anyMessage()]
    ) -> Self {
        
        Self(
            labelTag: labelTag,
            image: image,
            params: params
        )
    }
}

extension CollateralLandingStubProduct.Condition {
    
    static func stub(
        icon: String? = anyMessage(),
        title: String? = anyMessage(),
        subTitle: String? = anyMessage()
    ) -> Self {
        
        Self(
            icon: icon,
            title: title,
            subTitle: subTitle
        )
    }
}

extension CollateralLandingStubProduct.Calc {
    
    static func stub(
        amount: Amount? = .stub(),
        collateral: [Collateral]? = [.stub()],
        rates: [Rate]? = [.stub()]
    ) -> Self {
        
        Self(
            amount: amount,
            collateral: collateral,
            rates: rates
        )
    }
}

extension CollateralLandingStubProduct.Calc.Amount {
    
    static func stub(
        minIntValue: UInt? = .random(in: (0...UInt.max)),
        maxIntValue: UInt? = .random(in: (0...UInt.max)),
        maxStringValue: String? = anyMessage()
    ) -> Self {
        
        Self(
            minIntValue: minIntValue,
            maxIntValue: maxIntValue,
            maxStringValue: maxStringValue
        )
    }
}

extension CollateralLandingStubProduct.Calc.Collateral {
    
    static func stub(
        icon: String? = anyMessage(),
        name: String? = anyMessage(),
        type: String? = anyMessage()
    ) -> Self {
        
        Self(
            icon: icon,
            name: name,
            type: type
        )
    }
}

extension CollateralLandingStubProduct.Calc.Rate {
    
    static func stub(
        rateBase: Double? = .random(in: (0...Double.greatestFiniteMagnitude)),
        ratePayrollClient: Double? = .random(in: (0...Double.greatestFiniteMagnitude)),
        termMonth: UInt? = .random(in: (0...UInt.max)),
        termStringValue: String? = anyMessage()
    ) -> Self {
        
        Self(
            rateBase: rateBase,
            ratePayrollClient: ratePayrollClient,
            termMonth: termMonth,
            termStringValue: termStringValue
        )
    }
}

extension CollateralLandingStubProduct.FrequentlyAskedQuestion {
    
    static func stub(
        question: String? = anyMessage(),
        answer: String? = anyMessage()
    ) -> Self {
        
        Self(
            question: question,
            answer: answer
        )
    }
}

extension CollateralLandingStubProduct.Document {
    
    static func stub(
        title: String? = anyMessage(),
        icon: String? = anyMessage(),
        link: String? = anyMessage()
    ) -> Self {
        
        Self(
            title: title,
            icon: icon,
            link: link
        )
    }
}

extension CollateralLandingStubProduct.Consent {
    
    static func stub(
        name: String? = anyMessage(),
        link: String? = anyMessage()
    ) -> Self {
        
        Self(
            name: name,
            link: link
        )
    }
}

extension CollateralLandingStubProduct.Icons {
    
    static func stub(
        productName: String? = anyMessage(),
        amount: String? = anyMessage(),
        term: String? = anyMessage(),
        rate: String? = anyMessage(),
        city: String? = anyMessage()
    ) -> Self {
        
        Self(
            productName: productName,
            amount: amount,
            term: term,
            rate:rate,
            city: city
        )
    }
}
