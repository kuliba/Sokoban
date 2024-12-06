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
        
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(theme: nil)]))
        
        XCTAssertNoThrow(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutName() throws {

        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(name: nil)]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutMarketing() throws {

        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(marketing: nil)]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutConditions() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: nil)]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowsWithEmptyCondition() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }

    func test_map_shouldBeNoThrowsWithOneCondition() throws {
        
        let (icon, title, subTitle) = (anyMessage(), anyMessage(), anyMessage())
        let condition = makeCondition(icon: icon, title: title, subTitle: subTitle)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            [.init(icon: icon, title: title, subTitle: subTitle)]
        )
    }

    func test_map_shouldBeNoThrowsWithTwoCondition() throws {
        
        let (iconFirst, titleFirst, subTitleFirst) = (anyMessage(), anyMessage(), anyMessage())
        let (iconSecond, titleSecond, subTitleSecond) = (anyMessage(), anyMessage(), anyMessage())
        let conditionFirst = makeCondition(icon: iconFirst, title: titleFirst, subTitle: subTitleFirst)
        let conditionSecond = makeCondition(icon: iconSecond, title: titleSecond, subTitle: subTitleSecond)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [
            conditionFirst,
            conditionSecond
        ])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            [
                .init(icon: iconFirst, title: titleFirst, subTitle: subTitleFirst),
                .init(icon: iconSecond, title: titleSecond, subTitle: subTitleSecond)
            ]
        )
    }

    func test_map_shouldSkipConditionWithoutIcon() throws {
        
        let condition = makeCondition(icon: nil, title: anyMessage(), subTitle: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }
    
    func test_map_shouldSkipConditionWithoutTitle() throws {
        
        let condition = makeCondition(icon: anyMessage(), title: nil, subTitle: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }
    
    func test_map_shouldSkipConditionWithoutSubTitle() throws {
        
        let condition = makeCondition(icon: anyMessage(), title: anyMessage(), subTitle: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }
    
    func test_map_shouldSkipConditionWithoutIconAndTitle() throws {
        
        let condition = makeCondition(icon: nil, title: nil, subTitle: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }

    func test_map_shouldSkipConditionWithoutIconAndSubTitle() throws {
        
        let condition = makeCondition(icon: nil, title: anyMessage(), subTitle: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }

    func test_map_shouldSkipConditionWithoutTitleAndSubTitle() throws {
        
        let condition = makeCondition(icon: anyMessage(), title: nil, subTitle: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }

    func test_map_shouldSkipConditionWithoutIconAndTitleAndSubTitle() throws {
        
        let condition = makeCondition(icon: nil, title: nil, subTitle: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(conditions: [condition])]))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.conditions),
            []
        )
    }

    func test_map_shouldBeThrowsWithoutCalc() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(products: [makeProduct(calc: nil)]))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutFrequentlyAskedQuestions() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: nil)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyFrequentlyAskedQuestions() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: [])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.frequentlyAskedQuestions),
            []
        )
    }

    func test_map_shouldBeNoThrowWithTwoFrequentlyAskedQuestion() throws {
        
        let (questionFirst, answerFirst) = (anyMessage(), anyMessage())
        let (questionSecond, answerSecond) = (anyMessage(), anyMessage())
        let frequentlyAskedQuestionFirst = makeFrequentlyAskedQuestion(
            question: questionFirst,
            answer: answerFirst
        )
        let frequentlyAskedQuestionSecond = makeFrequentlyAskedQuestion(
            question: questionSecond,
            answer: answerSecond
        )
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: [
                frequentlyAskedQuestionFirst,
                frequentlyAskedQuestionSecond,
            ])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.frequentlyAskedQuestions),
            [
                .init(question: questionFirst, answer: answerFirst),
                .init(question: questionSecond, answer: answerSecond)
            ]
        )
    }

    func test_map_shouldSkipFrequentlyAskedQuestionWithoutQuestion() throws {
        
        let frequentlyAskedQuestion = makeFrequentlyAskedQuestion(question: nil, answer: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: [frequentlyAskedQuestion])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.frequentlyAskedQuestions),
            []
        )
    }

    func test_map_shouldSkipFrequentlyAskedQuestionWithoutAnswer() throws {
        
        let frequentlyAskedQuestion = makeFrequentlyAskedQuestion(question: anyMessage(), answer: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: [frequentlyAskedQuestion])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.frequentlyAskedQuestions),
            []
        )
    }

    func test_map_shouldSkipFrequentlyAskedQuestionWithoutQuestionAndAnswer() throws {
        
        let frequentlyAskedQuestion = makeFrequentlyAskedQuestion(question: nil, answer: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(frequentlyAskedQuestions: [frequentlyAskedQuestion])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.frequentlyAskedQuestions),
            []
        )
    }

    func test_map_shouldBeThrowsWithoutDocuments() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: nil)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyDocuments() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldBeNoThrowWithOneDocument() throws {
        
        let (title, icon, link) = (anyMessage(), anyMessage(), anyMessage())
        let document = makeDocument(title: title, icon: icon, link: link)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            [.init(title: title, icon: icon, link: link)]
        )
    }

    func test_map_shouldBeNoThrowWithTwoDocuments() throws {
        
        let (titleFirst, iconFirst, linkFirst) = (anyMessage(), anyMessage(), anyMessage())
        let (titleSecond, iconSecond, linkSecond) = (anyMessage(), anyMessage(), anyMessage())
        let documentFirst = makeDocument(title: titleFirst, icon: iconFirst, link: linkFirst)
        let documentSecond = makeDocument(title: titleSecond, icon: iconSecond, link: linkSecond)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [documentFirst, documentSecond])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            [
                .init(title: titleFirst, icon: iconFirst, link: linkFirst),
                .init(title: titleSecond, icon: iconSecond, link: linkSecond)
            ]
        )
    }

    func test_map_shouldSkipDocumentWithoutTitle() throws {
        
        let document = makeDocument(title: nil, icon: anyMessage(), link: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldNotSkipDocumentWithoutIcon() throws {
        
        let title = anyMessage()
        let link = anyMessage()
        
        let document = makeDocument(title: title, icon: nil, link: link)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            [.init(title: title, icon: nil, link: link)]
        )
    }

    func test_map_shouldSkipDocumentWithoutLink() throws {
        
        let document = makeDocument(title: anyMessage(), icon: anyMessage(), link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldSkipDocumentWithoutTitleAndIcon() throws {
        
        let document = makeDocument(title: nil, icon: nil, link: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldSkipDocumentWithoutTitleAndLink() throws {
        
        let document = makeDocument(title: nil, icon: anyMessage(), link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldSkipDocumentWithoutIconAndLink() throws {
        
        let document = makeDocument(title: anyMessage(), icon: nil, link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldSkipDocumentWithoutTitleAndIconAndLink() throws {
        
        let document = makeDocument(title: nil, icon: nil, link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(documents: [document])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.documents),
            []
        )
    }

    func test_map_shouldBeThrowsWithoutConsents() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: nil)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyConsents() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            []
        )
    }

    func test_map_shouldDeliverConsent() throws {
        
        let (name, link) = (anyMessage(), anyMessage())
        let consent = makeConsent(name: name, link: link)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [consent])]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            [.init(name: name, link: link)]
        )
    }

    func test_map_shouldSkipConsentWithoutName() throws {
        
        let consent = makeConsent(name: nil, link: anyMessage())
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [consent])]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            []
        )
    }

    func test_map_shouldSkipConsentWithoutLink() throws {
        
        let consent = makeConsent(name: anyMessage(), link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [consent])]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            []
        )
    }

    func test_map_shouldSkipConsentWithoutNameAndLink() throws {
        
        let consent = makeConsent(name: nil, link: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [consent])]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            []
        )
    }

    func test_map_shouldBeNoThrowValidWithTwoConsent() throws {
        
        let (nameFirst, linkFirst) = (anyMessage(), anyMessage())
        let (nameSecond, linkSecond) = (anyMessage(), anyMessage())
        let consentFirst = makeConsent(name: nameFirst, link: linkFirst)
        let consentSecond = makeConsent(name: nameSecond, link: linkSecond)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(consents: [consentFirst, consentSecond])]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            [
                .init(name: nameFirst, link: linkFirst),
                .init(name: nameSecond, link: linkSecond)
            ]
        )
    }

    func test_map_shouldBeThrowsWithoutCities() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(cities: nil)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCities() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(cities: [])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.consents),
            []
        )
    }
    
    func test_map_shouldBeNoThrowWithOneCity() throws {

        let city = anyMessage()
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(cities: [city])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.cities),
            [city]
        )
    }
    
    func test_map_shouldBeNoThrowWithTwoCity() throws {
        
        let cityFirst = anyMessage()
        let citySecond = anyMessage()
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(cities: [cityFirst, citySecond])])
        )

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.flatMap(\.cities),
            [cityFirst, citySecond]
        )
    }
    
    func test_map_shouldBeThrowsWithoutIcons() throws {
        
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(icons: nil)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutAnyParamInIcons() throws {
        
        var val: String { anyMessage() }
        
        try [
            makeIcons(productName: nil, amount: val, term: val, rate: val, city: val),
            makeIcons(productName: val, amount: nil, term: val, rate: val, city: val),
            makeIcons(productName: val, amount: val, term: nil, rate: val, city: val),
            makeIcons(productName: val, amount: val, term: val, rate: nil, city: val),
            makeIcons(productName: val, amount: val, term: val, rate: val, city: nil),
            makeIcons(productName: val, amount: nil, term: nil, rate: val, city: val),
            makeIcons(productName: val, amount: nil, term: val, rate: nil, city: val),
            makeIcons(productName: val, amount: nil, term: val, rate: val, city: nil),
            makeIcons(productName: val, amount: val, term: nil, rate: nil, city: val),
            makeIcons(productName: val, amount: val, term: nil, rate: val, city: nil),
            makeIcons(productName: val, amount: val, term: val, rate: nil, city: nil),
            makeIcons(productName: val, amount: val, term: nil, rate: nil, city: nil),
            makeIcons(productName: val, amount: nil, term: val, rate: nil, city: nil),
            makeIcons(productName: val, amount: nil, term: nil, rate: val, city: nil),
            makeIcons(productName: val, amount: nil, term: nil, rate: nil, city: val),
            makeIcons(productName: nil, amount: val, term: val, rate: nil, city: nil),
            makeIcons(productName: nil, amount: val, term: nil, rate: val, city: nil),
            makeIcons(productName: nil, amount: val, term: nil, rate: nil, city: val),
            makeIcons(productName: nil, amount: nil, term: val, rate: val, city: nil),
            makeIcons(productName: nil, amount: nil, term: val, rate: nil, city: val),
            makeIcons(productName: nil, amount: nil, term: nil, rate: val, city: val),
            makeIcons(productName: val, amount: nil, term: nil, rate: nil, city: nil),
            makeIcons(productName: nil, amount: val, term: nil, rate: nil, city: nil),
            makeIcons(productName: nil, amount: nil, term: val, rate: nil, city: nil),
            makeIcons(productName: nil, amount: nil, term: nil, rate: val, city: nil),
            makeIcons(productName: nil, amount: nil, term: nil, rate: nil, city: val),
            makeIcons(productName: nil, amount: nil, term: nil, rate: nil, city: nil)
        ].forEach {
            
            let stub = makeCodableResponse(data: makeSerialStamped(
                products: [makeProduct(icons: $0)]
            ))
            
            XCTAssertThrowsError(try map(stub.encoded()).get())
        }
    }
    
    func test_map_shouldBeThrowsWithoutMarketingLabelTag() throws {
        
        let marketing = makeMarketing(labelTag: nil, image: anyMessage(), params: [anyMessage()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutMarketingImage() throws {
        
        let marketing = makeMarketing(labelTag: anyMessage(), image: nil, params: [anyMessage()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutMarketingParams() throws {
        
        let marketing = makeMarketing(labelTag: anyMessage(), image: anyMessage(), params: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyMarketingParams() throws {
        
        let marketing = makeMarketing(labelTag: anyMessage(), image: anyMessage(), params: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.marketing.params,
            []
        )
    }
    
    func test_map_shouldBeNoThrowWithOneMarketingParams() throws {

        let param = anyMessage()
        let marketing = makeMarketing(labelTag: anyMessage(), image: anyMessage(), params: [param])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.marketing.params,
            [param]
        )
    }
    
    func test_map_shouldBeNoThrowWithTwoMarketingParams() throws {
        
        let paramFirst = anyMessage()
        let paramSecond = anyMessage()
        let marketing = makeMarketing(
            labelTag: anyMessage(),
            image: anyMessage(),
            params: [paramFirst, paramSecond]
        )
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(marketing: marketing)]
        ))
        
        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.marketing.params,
            [paramFirst, paramSecond]
        )
    }

    func test_map_shouldBeThrowsWithoutCalcAmount() throws {
        
        let calc = makeCalc(amount: nil, collateral: [.stub()], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcCollateral() throws {
        
        let calc = makeCalc(amount: .stub(), collateral: nil, rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmountAndCollateral() throws {
        
        let calc = makeCalc(amount: nil, collateral: nil, rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmountAndRates() throws {
        
        let calc = makeCalc(amount: nil, collateral: [.stub()], rates: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcCollateralAndRates() throws {
        
        let calc = makeCalc(amount: .stub(), collateral: nil, rates: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmountAndCollateralAndRates() throws {
        
        let calc = makeCalc(amount: nil, collateral: nil, rates: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCalcCollateral() throws {
        
        let calc = makeCalc(amount: .stub(), collateral: [], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldBeNoThrowWithOneCalcCollateral() throws {

        let icon = anyMessage()
        let name = anyMessage()
        let type = anyMessage()
        
        let collateral = makeCollateral(icon: icon, name: name, type: type)
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            [.init(icon: icon, name: name, type: type)]
        )
    }
    
    func test_map_shouldSkipCalcCollateralWithoutIcon() throws {

        let collateral = makeCollateral(icon: nil, name: anyMessage(), type: anyMessage())
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutName() throws {

        let collateral = makeCollateral(icon: anyMessage(), name: nil, type: anyMessage())
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutType() throws {

        let collateral = makeCollateral(icon: anyMessage(), name: anyMessage(), type: nil)
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutIconAndName() throws {

        let collateral = makeCollateral(icon: nil, name: nil, type: anyMessage())
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutIconAndType() throws {

        let collateral = makeCollateral(icon: nil, name: anyMessage(), type: nil)
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutNameAndType() throws {

        let collateral = makeCollateral(icon: anyMessage(), name: nil, type: nil)
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldSkipCalcCollateralWithoutIconAndNameAndType() throws {

        let collateral = makeCollateral(icon: nil, name: nil, type: nil)
        let calc = makeCalc(amount: .stub(), collateral: [collateral], rates: [.stub()])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            []
        )
    }

    func test_map_shouldBeNoThrowWithTwoCalcCollateral() throws {
        
        let iconFirst = anyMessage()
        let nameFirst = anyMessage()
        let typeFirst = anyMessage()
        let iconSecond = anyMessage()
        let nameSecond = anyMessage()
        let typeSecond = anyMessage()
        
        let collateralFirst = makeCollateral(icon: iconFirst, name: nameFirst, type: typeFirst)
        let collateralSecond = makeCollateral(icon: iconSecond, name: nameSecond, type: typeSecond)
        let calc = makeCalc(
            amount: .stub(),
            collateral: [collateralFirst, collateralSecond],
            rates: [.stub()]
        )
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.collateral,
            [
                .init(icon: iconFirst, name: nameFirst, type: typeFirst),
                .init(icon: iconSecond, name: nameSecond, type: typeSecond)
            ]
        )
    }

    func test_map_shouldBeThrowsWithoutCalcRates() throws {
        
        let calc = makeCalc(amount: .stub(), collateral: [.stub()], rates: nil)
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeNoThrowWithEmptyCalcRates() throws {
        
        let calc = makeCalc(amount: .stub(), collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.rates,
            []
        )
    }

    func test_map_shouldBeNoThrowWithOneCalcRates() throws {
        
        let rateBase = Double.random
        let ratePayrollClient = Double.random
        let termMonth = UInt.random
        let termStringValue = anyMessage()
        
        let rate = makeRate(
            rateBase: rateBase,
            ratePayrollClient: ratePayrollClient,
            termMonth: termMonth,
            termStringValue: termStringValue
        )
        
        let calc = makeCalc(amount: .stub(), collateral: [.stub()], rates: [rate])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.rates,
            [.init(
                rateBase: rateBase,
                ratePayrollClient: ratePayrollClient,
                termMonth: termMonth,
                termStringValue: termStringValue
            )]
        )
    }

    func test_map_shouldBeNoThrowWithTwoCalcRates() throws {
        
        let rateBaseFirst = Double.random
        let ratePayrollClientFirst = Double.random
        let termMonthFirst = UInt.random
        let termStringValueFirst = anyMessage()
        
        let rateBaseSecond = Double.random
        let ratePayrollClientSecond = Double.random
        let termMonthSecond = UInt.random
        let termStringValueSecond = anyMessage()
        
        let rateFirst = makeRate(
            rateBase: rateBaseFirst,
            ratePayrollClient: ratePayrollClientFirst,
            termMonth: termMonthFirst,
            termStringValue: termStringValueFirst
        )
        
        let rateSecond = makeRate(
            rateBase: rateBaseSecond,
            ratePayrollClient: ratePayrollClientSecond,
            termMonth: termMonthSecond,
            termStringValue: termStringValueSecond
        )
        
        let calc = makeCalc(amount: .stub(), collateral: [.stub()], rates: [rateFirst, rateSecond])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        try XCTAssertNoDiff(
            map(stub.encoded()).get().list.first?.calc.rates,
            [
                .init(
                    rateBase: rateBaseFirst,
                    ratePayrollClient: ratePayrollClientFirst,
                    termMonth: termMonthFirst,
                    termStringValue: termStringValueFirst
                ),
                .init(
                    rateBase: rateBaseSecond,
                    ratePayrollClient: ratePayrollClientSecond,
                    termMonth: termMonthSecond,
                    termStringValue: termStringValueSecond
                )
            ]
        )
    }

    func test_map_shouldBeThrowsWithoutCalcAmountMinIntValue() throws {
        
        let amount = makeAmount(minIntValue: nil, maxIntValue: .random, maxStringValue: anyMessage())
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowsWithoutCalcAmountMaxIntValue() throws {
        
        let amount = makeAmount(minIntValue: .random, maxIntValue: nil, maxStringValue: anyMessage())
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMaxStringValue() throws {
        
        let amount = makeAmount(minIntValue: .random, maxIntValue: .random, maxStringValue: nil)
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMinIntValueAndMaxIntValue() throws {
        
        let amount = makeAmount(minIntValue: nil, maxIntValue: nil, maxStringValue: anyMessage())
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMinIntValueAndMaxStringValue() throws {
        
        let amount = makeAmount(minIntValue: nil, maxIntValue: .random, maxStringValue: nil)
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMaxIntValueAndMaxStringValue() throws {
        
        let amount = makeAmount(minIntValue: .random, maxIntValue: nil, maxStringValue: nil)
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeThrowWithoutCalcAmountMaxIntValueAndMaxIntValueAndMaxStringValue() throws {
        
        let amount = makeAmount(minIntValue: nil, maxIntValue: nil, maxStringValue: nil)
        
        let calc = makeCalc(amount: amount, collateral: [.stub()], rates: [])
        let stub = makeCodableResponse(data: makeSerialStamped(
            products: [makeProduct(calc: calc)]
        ))

        XCTAssertThrowsError(try map(stub.encoded()).get())
    }

    func test_map_shouldBeSkipCalcRateWithoutOneOrMoreParams() throws {
        
        try [
            makeRate(rateBase: nil),
            makeRate(ratePayrollClient: nil),
            makeRate(termMonth: nil),
            makeRate(termStringValue: nil),
            makeRate(rateBase: nil, ratePayrollClient: nil),
            makeRate(rateBase: nil, termMonth: nil),
            makeRate(rateBase: nil, termStringValue: nil),
            makeRate(ratePayrollClient: nil, termMonth: nil),
            makeRate(ratePayrollClient: nil, termStringValue: nil),
            makeRate(termMonth: nil, termStringValue: nil),
            makeRate(ratePayrollClient: nil, termMonth: nil, termStringValue: nil),
            makeRate(rateBase: nil, termMonth: nil, termStringValue: nil),
            makeRate(rateBase: nil, ratePayrollClient: nil, termStringValue: nil),
            makeRate(rateBase: nil, ratePayrollClient: nil, termMonth: nil),
            makeRate(rateBase: nil, ratePayrollClient: nil, termMonth: nil, termStringValue: nil)
        ].forEach {
            
            let stub = makeCodableResponse(data: makeSerialStamped(
                products: [makeProduct(calc: makeCalc(
                    amount: .stub(),
                    collateral: [.stub()],
                    rates: [$0]))]
            ))
            
            try XCTAssertNoDiff(
                map(stub.encoded()).get().list.first?.calc.rates,
                []
            )
        }
    }

    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.MappingResult<ResponseMapper.GetCollateralLandingResponse>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> Response {
        
        ResponseMapper.mapCreateGetCollateralLandingResponse(data, httpURLResponse)
    }
    
    private func mapAndGetProductFromStub(_ stub: CodableResponse) throws -> ResponseMapper.CollateralLandingProduct {
        
        try XCTUnwrap(map(try stub.encoded()).get().list.first)
    }
}

private func makeCodableResponse(
    statusCode: Int = 200,
    errorMessage: String? = nil,
    data: CodableResponse.SerialStamped = makeSerialStamped()
) -> CodableResponse {
    
    return .init(statusCode: statusCode, errorMessage: errorMessage, data: data)
}

private func makeSerialStamped(
    serial: String = anyMessage(),
    products: [CollateralLandingStubProduct] = []
) -> CodableResponse.SerialStamped{
    
    return .init(serial: serial, products: products)
}

private func makeProduct(
    theme: CollateralLandingStubProduct.Theme? = .stub(),
    name: String? = anyMessage(),
    marketing: CollateralLandingStubProduct.Marketing? = .stub(),
    conditions: [CollateralLandingStubProduct.Condition]? = [],
    calc: CollateralLandingStubProduct.Calc? = .stub(),
    frequentlyAskedQuestions: [CollateralLandingStubProduct.FrequentlyAskedQuestion]? = [],
    documents: [CollateralLandingStubProduct.Document]? = [],
    consents: [CollateralLandingStubProduct.Consent]? = [],
    cities: [String]? = [],
    icons: CollateralLandingStubProduct.Icons? = .stub()
) -> CollateralLandingStubProduct {
    
    return .init(
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

private func makeConsent(
    name: String?,
    link: String?
) -> CollateralLandingStubProduct.Consent {
    
    return .init(name: name, link: link)
}

private func makeCondition(
    icon: String?,
    title: String?,
    subTitle: String?
) -> CollateralLandingStubProduct.Condition {
    
    .init(icon: icon, title: title, subTitle: subTitle)
}

private func makeFrequentlyAskedQuestion(
    question: String?,
    answer: String?
) -> CollateralLandingStubProduct.FrequentlyAskedQuestion {
    
    .init(question: question, answer: answer)
}

private func makeDocument(
    title: String?,
    icon: String?,
    link: String?
) -> CollateralLandingStubProduct.Document {
    
    .init(title: title, icon: icon, link: link)
}

private func makeIcons(
    productName: String?,
    amount: String?,
    term: String?,
    rate: String?,
    city: String?
) -> CollateralLandingStubProduct.Icons {
    
    .init(productName: productName, amount: amount, term: term, rate: rate, city: city)
}

private func makeMarketing(
    labelTag: String?,
    image: String?,
    params: [String]?
) -> CollateralLandingStubProduct.Marketing {
    
    .init(labelTag: labelTag, image: image, params: params)
}

private func makeCalc(
    amount: CollateralLandingStubProduct.Calc.Amount?,
    collateral: [CollateralLandingStubProduct.Calc.Collateral]?,
    rates: [CollateralLandingStubProduct.Calc.Rate]?
) -> CollateralLandingStubProduct.Calc {
    
    .init(
        amount: amount,
        collateral: collateral,
        rates: rates
    )
}

private func makeCollateral(
    icon: String?,
    name: String?,
    type: String?
) -> CollateralLandingStubProduct.Calc.Collateral {
    
    .init(icon: icon, name: name, type: type)
}

private func makeRate(
    rateBase: Double? = .random,
    ratePayrollClient: Double? = .random,
    termMonth: UInt? = .random,
    termStringValue: String? = anyMessage()
) -> CollateralLandingStubProduct.Calc.Rate {
    
    .init(
        rateBase: rateBase,
        ratePayrollClient: ratePayrollClient,
        termMonth: termMonth,
        termStringValue: termStringValue
    )
}

private func makeAmount(
    minIntValue: UInt?,
    maxIntValue: UInt?,
    maxStringValue: String?
) -> CollateralLandingStubProduct.Calc.Amount {
    
    .init(
        minIntValue: minIntValue,
        maxIntValue: maxIntValue,
        maxStringValue: maxStringValue
    )
}

private struct CodableResponse: Encodable {
    
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
        minIntValue: UInt? = .random,
        maxIntValue: UInt? = .random,
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
        rateBase: Double? = .random,
        ratePayrollClient: Double? = .random,
        termMonth: UInt? = .random,
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
