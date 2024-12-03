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
        
        let invalidData = try XCTUnwrap("invalid data".data(using: .utf8))
        
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
    
    func test_map_shouldBeNoThrowWithoutTheme() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(theme: nil)
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutName() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(name: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutMarketing() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutConditions() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowsWithEmptyCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [])
            ]))
        
        XCTAssertNoThrow(try map(stub.encoded()).get())

        let conditions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.conditions)

        XCTAssertTrue(conditions.isEmpty)
    }

    func test_map_shouldBeNoThrowsWithOneCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [.stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let conditions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.conditions)

        XCTAssertTrue(conditions.count == 1)
    }

    func test_map_shouldBeNoThrowsWithTwoCondition() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [.stub(), .stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let conditions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.conditions)

        XCTAssertTrue(conditions.count == 2)
    }

    func test_map_shouldBeThrowsWithoutCalc() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutFrequentlyAskedQuestions() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyFrequentlyAskedQuestions() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: [])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let frequentlyAskedQuestions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.frequentlyAskedQuestions)

        XCTAssertTrue(frequentlyAskedQuestions.isEmpty)
    }

    func test_map_shouldBeNoThrowWithOneFrequentlyAskedQuestion() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: [.stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let frequentlyAskedQuestions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.frequentlyAskedQuestions)

        XCTAssertTrue(frequentlyAskedQuestions.count == 1)
    }

    func test_map_shouldBeNoThrowWithTwoFrequentlyAskedQuestion() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: [.stub(), .stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let frequentlyAskedQuestions = try XCTUnwrap(try map(stub.encoded()).get().list.first?.frequentlyAskedQuestions)

        XCTAssertTrue(frequentlyAskedQuestions.count == 2)
    }

    func test_map_shouldBeThrowsWithoutDocuments() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyDocuments() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let documents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.documents)

        XCTAssertTrue(documents.isEmpty)
    }

    func test_map_shouldBeNoThrowWithOneDocument() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [.stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let documents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.documents)

        XCTAssertTrue(documents.count == 1)
    }

    func test_map_shouldBeNoThrowWithTwoDocuments() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [.stub(), .stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let documents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.documents)

        XCTAssertTrue(documents.count == 2)
    }

    func test_map_shouldBeThrowsWithoutConsents() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyConsents() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: [])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let consents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.consents)

        XCTAssertTrue(consents.isEmpty)
    }

    func test_map_shouldBeNoThrowWithOneConsent() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: [.stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())

        let consents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.consents)

        XCTAssertTrue(consents.count == 1)
    }

    func test_map_shouldBeNoThrowValidWithTwoConsent() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: [.stub(), .stub()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let consents = try XCTUnwrap(try map(stub.encoded()).get().list.first?.consents)

        XCTAssertTrue(consents.count == 2)
    }

    func test_map_shouldBeThrowsWithoutCities() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(cities: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCities() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(cities: [])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let cities = try XCTUnwrap(try map(stub.encoded()).get().list.first?.cities)

        XCTAssertTrue(cities.isEmpty)
    }
    
    func test_map_shouldBeNoThrowWithOneCity() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(cities: [anyMessage()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let cities = try XCTUnwrap(try map(stub.encoded()).get().list.first?.cities)

        XCTAssertTrue(cities.count == 1)
    }
    
    func test_map_shouldBeNoThrowWithTwoCity() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(cities: [anyMessage(), anyMessage()])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let cities = try XCTUnwrap(try map(stub.encoded()).get().list.first?.cities)

        XCTAssertTrue(cities.count == 2)
    }
    
    func test_map_shouldBeThrowsWithoutIcons() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: nil)
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutMarketingLabelTag() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(labelTag: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutMarketingImage() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(image: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(params: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(params: []))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let params = try XCTUnwrap(try map(stub.encoded()).get().list.first?.marketing.params)

        XCTAssertTrue(params.isEmpty)
    }
    
    func test_map_shouldBeNoThrowWithOneMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(params: [anyMessage()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let params = try XCTUnwrap(try map(stub.encoded()).get().list.first?.marketing.params)

        XCTAssertTrue(params.count == 1)
    }
    
    func test_map_shouldBeNoThrowWithTwoMarketingParams() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(marketing: .stub(params: [anyMessage(), anyMessage()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let params = try XCTUnwrap(try map(stub.encoded()).get().list.first?.marketing.params)

        XCTAssertTrue(params.count == 1)
    }
    
    func test_map_shouldBeNoThrowWithoutConditionIcon() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [.stub(icon: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutConditionTitle() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [.stub(title: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutConditionSubtitle() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(conditions: [.stub(title: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmount() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(amount: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: []))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let collateral = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.collateral)

        XCTAssertTrue(collateral.isEmpty)
    }

    func test_map_shouldBeNoThrowWithOneCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: [.stub()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let collateral = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.collateral)

        XCTAssertTrue(collateral.count == 1)
    }

    func test_map_shouldBeNoThrowWithTwoCalcCollateral() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: [.stub(), .stub()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let collateral = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.collateral)

        XCTAssertTrue(collateral.count == 2)
    }

    func test_map_shouldBeThrowsWithoutCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: []))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let rates = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.rates)

        XCTAssertTrue(rates.isEmpty)
    }

    func test_map_shouldBeNoThrowWithOneCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
        
        let rates = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.rates)

        XCTAssertTrue(rates.count == 1)
    }

    func test_map_shouldBeNoThrowWithTwoCalcRates() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub(), .stub()]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())

        let rates = try XCTUnwrap(try map(stub.encoded()).get().list.first?.calc.rates)

        XCTAssertTrue(rates.count == 2)
    }

    func test_map_shouldBeThrowsWithoutCalcAmountMinIntValue() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(amount: .stub(minIntValue: nil)))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmountMaxIntValue() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(amount: .stub(maxIntValue: nil)))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMaxStringValue() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(amount: .stub(maxStringValue: nil)))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcCollateralIcon() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: [.stub(icon: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcCollateralName() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: [.stub(name: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcCollateralType() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(collateral: [.stub(type: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcRateRateBase() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub(rateBase: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcRateRatePayrollClient() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub(ratePayrollClient: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcRateTermMonth() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub(termMonth: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutCalcRateTermStringValue() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(calc: .stub(rates: [.stub(termStringValue: nil)]))
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutFrequentlyAskedQuestionQuestion() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: [.stub(question: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutFrequentlyAskedQuestionAnswer() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(frequentlyAskedQuestions: [.stub(answer: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutDocumentTitle() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [.stub(title: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutDocumentIcon() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [.stub(icon: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }
    
    func test_map_shouldBeNoThrowWithoutDocumentLink() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(documents: [.stub(link: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutConsentName() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: [.stub(name: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithoutConsentLink() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(consents: [.stub(link: nil)])
            ]))

        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutIconsProductName() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: .stub(productName: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutIconsAmount() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: .stub(amount: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutIconsTerm() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: .stub(term: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutIconsRate() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: .stub(rate: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutIconsCity() throws {
        
        let stub = CodableResponse(
            statusCode: 200,
            errorMessage: nil,
            data: .init(serial: anyMessage(), products: [
                .stub(icons: .stub(city: nil))
            ]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
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
