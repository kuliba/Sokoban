//
//  ResponseMapper+mapCreateCreditCardLandingAndApplicationResponseTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2025.
//

extension ResponseMapper {
    
    struct CreateCreditCardLandingAndApplication: Equatable {
        
        let application: Application
        let banner: Banner
        let consent: Consent
        let faq: FAQ
        let header: Header?
        let offer: Offer
        let offerConditions: OfferConditions
        let theme: String
    }
}

extension ResponseMapper.CreateCreditCardLandingAndApplication {
    
    struct Application: Equatable {
        
        let id: Int
        let status: String
    }
    
    struct Banner: Equatable {
        
        let background: String
        let conditions: [String]
    }
    
    struct Consent: Equatable {
        
        let terms: String
        let tariffs: String
        let creditHistoryRequest: String
    }
    
    struct FAQ: Equatable {
        
        let title: String
        let list: [Item]
        
        struct Item: Equatable {
            
            let title: String
            let description: String
        }
    }
    
    struct Header: Equatable {
        
        let title: String
        let subtitle: String
    }
    
    struct Offer: Equatable {
        
        let id: String
        let gracePeriod: String
        let tarifPlanRate: String
        let offerPeriodValidity: String
        let offerLimitAmount: String
        let tarifPlanName: String
        let icon: String
    }
    
    struct OfferConditions: Equatable {
        
        let title: String
        // TODO: improve with non-empty
        let list: [Condition]
        
        struct Condition: Equatable {
            
            let md5hash: String
            let title: String
            let subtitle: String
        }
    }
}

extension ResponseMapper {
    
    static func mapCreateCreditCardLandingAndApplicationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateCreditCardLandingAndApplication> {
        
        map(data, httpURLResponse, mapOrThrow: CreateCreditCardLandingAndApplication.init(data:))
    }
}

private extension ResponseMapper.CreateCreditCardLandingAndApplication {
    
    init(data: ResponseMapper._DTO) throws {
        
        guard let application = data._application,
              let banner = data._banner,
              let consent = data._consent,
              let faq = data._faq,
              let offer = data._offer,
              let offerConditions = data._offerConditions,
              let theme = data.theme
        else { throw ResponseFailure() }
        
        self.init(
            application: application,
            banner: banner,
            consent: consent,
            faq: faq,
            header: data._header,
            offer: offer,
            offerConditions: offerConditions,
            theme: theme
        )
    }
    
    struct ResponseFailure: Error {}
}

// MARK: - Mapping

private extension ResponseMapper._DTO {
    
    typealias Response = ResponseMapper.CreateCreditCardLandingAndApplication
    
    var _application: Response.Application? {
        
        guard let id = application?.id,
              let status = application?.status
        else { return nil }
        
        return .init(id: id, status: status)
    }
    
    var _banner: Response.Banner? {
        
        guard let background = banner?.background
        else { return nil }
        
        let conditions = banner?.highlightedOfferConditions ?? []
        
        return .init(background: background, conditions: conditions)
    }
    
    var _consent: Response.Consent? {
        
        guard let terms = consent?.terms,
              let tariffs = consent?.tariffs,
              let creditHistoryRequest = consent?.creditHistoryRequest
        else { return nil }
        
        return .init(terms: terms, tariffs: tariffs, creditHistoryRequest: creditHistoryRequest)
    }
    
    var _faq: Response.FAQ? {
        
        guard let title = frequentlyAskedQuestions?.title,
              let faqList,
              !faqList.isEmpty
        else { return nil }
        
        return .init(title: title, list: faqList)
    }
    
    var faqList: [Response.FAQ.Item]? {
        
        frequentlyAskedQuestions?.list?.compactMap(\.item)
    }
    
    var _header: Response.Header? {
        
        guard let title = header?.title,
              let subtitle = header?.subtitle
        else { return nil }
        
        return .init(title: title, subtitle: subtitle)
    }
    
    var _offer: Response.Offer? {
        
        guard
            let id = offer?.id,
            let gracePeriod = offer?.gracePeriod,
            let tarifPlanRate = offer?.tarifPlanRate,
            let offerPeriodValidity = offer?.offerPeriodValidity,
            let offerLimitAmount = offer?.offerLimitAmount,
            let tarifPlanName = offer?.tarifPlanName,
            let icon = offer?.icon
        else { return nil }
        
        return .init(
            id: id,
            gracePeriod: gracePeriod,
            tarifPlanRate: tarifPlanRate,
            offerPeriodValidity: offerPeriodValidity,
            offerLimitAmount: offerLimitAmount,
            tarifPlanName: tarifPlanName,
            icon: icon
        )
    }
    
    var _offerConditions: Response.OfferConditions? {
        
        guard let title = offerConditions?.title,
              let offerConditionsList,
              !offerConditionsList.isEmpty
        else { return nil }
        
        return .init(title: title, list: offerConditionsList)
    }
    
    var offerConditionsList: [Response.OfferConditions.Condition]? {
        
        offerConditions?.list?.compactMap(\.condition)
    }
}

private extension ResponseMapper._DTO._OfferConditions._Condition {
    
    typealias Condition = ResponseMapper.CreateCreditCardLandingAndApplication.OfferConditions.Condition
    
    var condition: Condition? {
        
        guard let md5hash, let title, let subtitle = subtitle ?? subTitle
        else { return nil }
        
        return .init(md5hash: md5hash, title: title, subtitle: subtitle)
    }
}

private extension ResponseMapper._DTO._FAQ._Item {
    
    typealias Item = ResponseMapper.CreateCreditCardLandingAndApplication.FAQ.Item
    
    var item: Item? {
        
        guard let title, let description
        else { return nil }
        
        return .init(title: title, description: description)
    }
}

// MARK: - DTO

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let application: _Application?
        let banner: _Banner?
        let consent: _Consent?
        let frequentlyAskedQuestions: _FAQ?
        let header: _Header?
        let offer: _Offer?
        let offerConditions: _OfferConditions?
        let theme: String?
    }
}

extension ResponseMapper._DTO {
    
    struct _Application: Decodable {
        
        let id: Int?
        let status: String?
    }
    
    struct _Banner: Decodable {
        
        let background: String?
        let highlightedOfferConditions: [String]?
    }
    
    struct _Consent: Decodable {
        
        let terms: String?
        let tariffs: String?
        let creditHistoryRequest: String?
    }
    
    struct _FAQ: Decodable {
        
        let title: String?
        let list: [_Item]?
        
        struct _Item: Decodable {
            
            let title: String?
            let description: String?
        }
    }
    
    struct _Header: Decodable {
        
        let title: String?
        let subtitle: String?
    }
    
    struct _Offer: Decodable {
        
        let id: String?
        let gracePeriod: String?
        let tarifPlanRate: String?
        let offerPeriodValidity: String?
        let offerLimitAmount: String?
        let tarifPlanName: String?
        let icon: String?
    }
    
    struct _OfferConditions: Decodable {
        
        let title: String?
        let list: [_Condition]?
        
        struct _Condition: Decodable {
            
            let md5hash: String?
            let title: String?
            let subtitle: String?
            let subTitle: String?
        }
    }
}

import CreditCardMVPBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapCreateCreditCardLandingAndApplicationResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailure_onEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onInvalidData() {
        
        assert(json: .invalidData, delivers: .invalid(
            statusCode: 200,
            data: .invalidData
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyJSON() {
        
        assert(json: .emptyJSON, delivers: .invalid(
            statusCode: 200,
            data: .emptyJSON
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyDataResponse() {
        
        assert(json: .emptyDataResponse, delivers: .invalid(
            statusCode: 200,
            data: .emptyDataResponse
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onNullServerResponse() {
        
        assert(json: .nullServerResponse, delivers: .invalid(
            statusCode: 200,
            data: .nullServerResponse
        ))
    }
    
    func test_map_shouldDeliverServerError_onServerError() {
        
        assert(json: .serverError, delivers: .server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        ))
    }
    
    func test_map_shouldDeliverInvalidFailure_onNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let json = String.validData()
            let validData = json.json
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            assert(
                json: json,
                httpURLResponse: nonOkResponse,
                delivers: .invalid(statusCode: statusCode, data: validData)
            )
        }
    }
    
    func test_map_shouldDeliverResponse_onValidData() throws {
        
        assert(json: ._source, delivers: makeResponse())
    }
    
    func test_map_shouldDeliverFailure_onResponseWithoutTheme() throws {
        
        assert(
            json: .withMissingTheme,
            delivers: .invalid(statusCode: 200, data: String.withMissingTheme.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithTheme() throws {
        
        let theme = anyMessage()
        
        assert(
            json: .validData(theme: theme),
            delivers: makeResponse(theme: theme)
        )
    }
    
    func test_map_shouldDeliverResponseWithoutHeader_onMissingHeaderTitle() throws {
        
        assert(
            json: .withMissingHeaderTitle,
            delivers: makeResponse(header: nil)
        )
    }
    
    func test_map_shouldDeliverResponseWithHeaderTitle() throws {
        
        let headerTitle = anyMessage()
        
        assert(
            json: .validData(headerTitle: headerTitle),
            delivers: makeResponse(headerTitle: headerTitle)
        )
    }
    
    func test_map_shouldDeliverResponseWithHeaderSubtitle() throws {
        
        let headerSubtitle = anyMessage()
        
        assert(
            json: .validData(headerSubtitle: headerSubtitle),
            delivers: makeResponse(headerSubtitle: headerSubtitle)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingBannerBackground() throws {
        
        assert(
            json: .withMissingBannerBackground,
            delivers: .invalid(statusCode: 200, data: String.withMissingBannerBackground.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithBannerBackground() throws {
        
        let bannerBackground = anyMessage()
        
        assert(
            json: .validData(bannerBackground: bannerBackground),
            delivers: makeResponse(bannerBackground: bannerBackground)
        )
    }
    
    func test_map_shouldDeliverResponseWithEmptyHighlightedOfferConditions_onMissingBannerConditions() throws {
        
        assert(
            json: .withMissingHighlightedOfferConditions,
            delivers: makeResponse(bannerConditions: [])
        )
    }
    
    func test_map_shouldDeliverResponseWithHighlightedOfferCondition() throws {
        
        let condition = anyMessage()
        
        assert(
            json: .validData(conditions: [condition]),
            delivers: makeResponse(bannerConditions: [condition])
        )
    }
    
    func test_map_shouldDeliverResponseWithHighlightedOfferConditions() throws {
        
        let (condition1, condition2) = (anyMessage(), anyMessage())
        
        assert(
            json: .validData(conditions: [condition1, condition2]),
            delivers: makeResponse(bannerConditions: [condition1, condition2])
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferConditionsTitle() throws {
        
        assert(
            json: .withMissingOfferConditionsTitle,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferConditionsTitle.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithOfferConditionsTitle() throws {
        
        let title = anyMessage()
        
        assert(
            json: .validData(offerConditionsTitle: title),
            delivers: makeResponse(offerConditions: makeOfferConditions(title: title))
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferConditionsList() throws {
        
        assert(
            json: .withMissingOfferConditionsList,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferConditionsList.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onEmptyOfferConditionsList() throws {
        
        assert(
            json: .withEmptyOfferConditionsList,
            delivers: .invalid(statusCode: 200, data: String.withEmptyOfferConditionsList.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingFAQTitle() throws {
        
        assert(
            json: .withMissingFAQTitle,
            delivers: .invalid(statusCode: 200, data: String.withMissingFAQTitle.json)
        )
    }
    
    func test_map_shouldDeliverResponseWithFAQTitle() throws {
        
        let title = anyMessage()
        
        assert(
            json: .validData(faqTitle: title),
            delivers: makeResponse(faq: makeFAQ(title: title))
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingFAQList() throws {
        
        assert(
            json: .withMissingFAQList,
            delivers: .invalid(statusCode: 200, data: String.withMissingFAQList.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onEmptyFAQList() throws {
        
        assert(
            json: .withEmptyFAQList,
            delivers: .invalid(statusCode: 200, data: String.withEmptyFAQList.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingConsent() throws {
        
        assert(
            json: .withMissingConsent,
            delivers: .invalid(statusCode: 200, data: String.withMissingConsent.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingConsentTerms() throws {
        
        assert(
            json: .withMissingConsentTerms,
            delivers: .invalid(statusCode: 200, data: String.withMissingConsentTerms.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingConsentTariffs() throws {
        
        assert(
            json: .withMissingConsentTariffs,
            delivers: .invalid(statusCode: 200, data: String.withMissingConsentTariffs.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingConsentCreditHistoryRequest() throws {
        
        assert(
            json: .withMissingConsentCreditHistoryRequest,
            delivers: .invalid(statusCode: 200, data: String.withMissingConsentCreditHistoryRequest.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingApplication() throws {
        
        assert(
            json: .withMissingApplication,
            delivers: .invalid(statusCode: 200, data: String.withMissingApplication.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingApplicationID() throws {
        
        assert(
            json: .withMissingApplicationID,
            delivers: .invalid(statusCode: 200, data: String.withMissingApplicationID.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingApplicationStatus() throws {
        
        assert(
            json: .withMissingApplicationStatus,
            delivers: .invalid(statusCode: 200, data: String.withMissingApplicationStatus.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOffer() throws {
        
        assert(
            json: .withMissingOffer,
            delivers: .invalid(statusCode: 200, data: String.withMissingOffer.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferID() throws {
        
        assert(
            json: .withMissingOfferID,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferID.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferGracePeriod() throws {
        
        assert(
            json: .withMissingOfferGracePeriod,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferGracePeriod.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferTarifPlanRate() throws {
        
        assert(
            json: .withMissingOfferTarifPlanRate,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferTarifPlanRate.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferPeriodValidity() throws {
        
        assert(
            json: .withMissingOfferPeriodValidity,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferPeriodValidity.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferLimitAmount() throws {
        
        assert(
            json: .withMissingOfferLimitAmount,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferLimitAmount.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferTarifPlanName() throws {
        
        assert(
            json: .withMissingOfferTarifPlanName,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferTarifPlanName.json)
        )
    }
    
    func test_map_shouldDeliverFailure_onMissingOfferIcon() throws {
        
        assert(
            json: .withMissingOfferIcon,
            delivers: .invalid(statusCode: 200, data: String.withMissingOfferIcon.json)
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateCreditCardLandingAndApplication
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCreateCreditCardLandingAndApplicationResponse(data, httpURLResponse)
    }
    
    private func makeResponse(
        theme: String = "DEFAULT",
        header: Response.Header?,
        banner: Response.Banner? = nil,
        offerConditions: Response.OfferConditions? = nil,
        faq: Response.FAQ? = nil,
        consent: Response.Consent? = nil,
        application: Response.Application? = nil,
        offer: Response.Offer? = nil
    ) -> Response {
        
        return .init(
            application: application ?? makeApplication(),
            banner: banner ?? makeBanner(),
            consent: consent ?? makeConsent(),
            faq: faq ?? makeFAQ(),
            header: header,
            offer: offer ?? makeOffer(),
            offerConditions: offerConditions ?? makeOfferConditions(),
            theme: theme
        )
    }
    
    private func makeApplication(
        id: Int = 123456789,
        status: String = "DRAFT"
    ) -> Response.Application {
        
        return .init(id: id, status: status)
    }
    
    private func makeBanner(
        background: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        conditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ]
    ) -> Response.Banner {
        
        return .init(background: background, conditions: conditions)
    }
    
    private func makeConsent(
        terms: String = "https://www.forabank.ru/dkbo/dkbo.pdf",
        tariffs: String = "https://www.forabank.ru/tarify/",
        creditHistoryRequest: String = "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    ) -> Response.Consent {
        
        return .init(terms: terms, tariffs: tariffs, creditHistoryRequest: creditHistoryRequest)
    }
    
    private func makeOffer(
        id: String = "123",
        gracePeriod: String = "36",
        tarifPlanRate: String = "69.99",
        offerPeriodValidity: String = "2025-03-31",
        offerLimitAmount: String = "10000.00",
        tarifPlanName: String = "ТП1",
        icon: String = "37baa2ff94fb468f65fa0ea4017bf44a"
    ) -> Response.Offer {
        
        return .init(
            id: id,
            gracePeriod: gracePeriod,
            tarifPlanRate: tarifPlanRate,
            offerPeriodValidity: offerPeriodValidity,
            offerLimitAmount: offerLimitAmount,
            tarifPlanName: tarifPlanName,
            icon: icon
        )
    }
    
    private func makeOfferConditions(
        title: String = "Персональное предложение",
        list: [Response.OfferConditions.Condition]? = nil
    ) -> Response.OfferConditions {
        
        return .init(
            title: title,
            list: list ?? [
                makeOfferCondition(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Процентная ставка",
                    subtitle: "6,5 % годовых"
                ),
                makeOfferCondition(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Срок льготного периода",
                    subtitle: "До 62 дней"
                ),
                makeOfferCondition(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Стоимость обслуживания",
                    subtitle: "Бесплатно навсегда"
                ),
                makeOfferCondition(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Оформление",
                    subtitle: "В отделении Банка"
                )
            ]
        )
    }
    
    private func makeOfferCondition(
        md5hash: String = anyMessage(),
        title: String = anyMessage(),
        subtitle: String = anyMessage()
    ) -> Response.OfferConditions.Condition {
        
        return .init(md5hash: md5hash, title: title, subtitle: subtitle)
    }
    
    private func makeFAQ(
        title: String = "Часто задаваемые вопросы",
        list: [Response.FAQ.Item]? = nil
    ) -> Response.FAQ {
        
        return .init(
            title: title,
            list: list ?? [
                makeFAQItem(
                    title: "Как повторно подключить подписку?",
                    description: "тест"
                ),
                makeFAQItem(
                    title: "Как начисляются проценты?",
                    description: "тесттесттесттесттесттесттесттест"
                ),
                makeFAQItem(
                    title: "Какие условия бесплатного обслуживания?",
                    description: ""
                )
            ]
        )
    }
    
    private func makeFAQItem(
        title: String = anyMessage(),
        description: String = anyMessage()
    ) -> Response.FAQ.Item {
        
        return .init(title: title, description: description)
    }
    
    private func makeResponse(
        theme: String = "DEFAULT",
        headerTitle: String = "Кредитная карта",
        headerSubtitle: String = "«Все включено»",
        bannerBackground: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        bannerConditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ],
        offerConditions: Response.OfferConditions? = nil,
        faq: Response.FAQ? = nil,
        consent: Response.Consent? = nil,
        application: Response.Application? = nil,
        offer: Response.Offer? = nil
    ) -> Response {
        
        return .init(
            application: application ?? makeApplication(),
            banner: .init(
                background: bannerBackground,
                conditions: bannerConditions
            ),
            consent: consent ?? makeConsent(),
            faq: faq ?? makeFAQ(),
            header: .init(
                title: headerTitle,
                subtitle: headerSubtitle
            ),
            offer: offer ?? makeOffer(),
            offerConditions: offerConditions ?? makeOfferConditions(),
            theme: theme
        )
    }
    
    private func assert(
        json: String,
        httpURLResponse: HTTPURLResponse = anyHTTPURLResponse(),
        delivers response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(map(.init(json.utf8), httpURLResponse), .success(response), file: file, line: line)
    }
    
    private func assert(
        json: String,
        httpURLResponse: HTTPURLResponse = anyHTTPURLResponse(),
        delivers failure: ResponseMapper.MappingError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(map(.init(json.utf8), httpURLResponse), .failure(failure), file: file, line: line)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static func validData(
        theme: String = "DEFAULT",
        headerTitle: String = "Кредитная карта",
        headerSubtitle: String = "«Все включено»",
        bannerBackground: String = "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
        conditions: [String] = [
            "Вам одобрена сумма 97 000 ₽",
            "Предложение действует до 30.04.2025"
        ],
        offerConditionsTitle: String = "Персональное предложение",
        faqTitle: String = "Часто задаваемые вопросы"
    ) -> String {
        
"""
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "\(theme)",
    "header": {
      "title": "\(headerTitle)",
      "subtitle": "\(headerSubtitle)"
    },
    "banner": {
      "background": "\(bannerBackground)",
      "highlightedOfferConditions": \(conditions)
    },
    "offerConditions": {
      "title": "\(offerConditionsTitle)",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "\(faqTitle)",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    }
    
    static let withMissingHeaderTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "subtitle": "«Все включено»"
    },
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingHighlightedOfferConditions = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png"
    },
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingTheme = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingBannerBackground = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": {
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingOfferConditionsTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": {
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingOfferConditionsList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": {
      "title": "Персональное предложение"
    },
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withEmptyOfferConditionsList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": {
      "title": "Персональное предложение",
      "list": []
    },
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingFAQTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": {
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingFAQList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы"
    },
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withEmptyFAQList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": []
    },
    "consent": \(_consent),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingConsent = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingConsentTerms = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": {
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingConsentTariffs = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingConsentCreditHistoryRequest = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/"
    },
    "application": \(_application),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingApplication = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingApplicationID = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": {
      "status": "DRAFT"
    },
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingApplicationStatus = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": {
      "id": 123456789
    },
    "offer": \(_offer)
  }
}
"""
    
    static let withMissingOffer = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
  }
}
"""
    
    static let withMissingOfferID = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferGracePeriod = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferTarifPlanRate = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferPeriodValidity = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferLimitAmount = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferTarifPlanName = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
    
    static let withMissingOfferIcon = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": \(_header),
    "banner": \(_banner),
    "offerConditions": \(_offerConditions),
    "frequentlyAskedQuestions": \(_faq),
    "consent": \(_consent),
    "application": \(_application),
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1"
    }
  }
}
"""
    
    // MARK: - blocks
    
    static let _header = """
{
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    }
"""
    
    static let _banner = """
{
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    }
"""
    
    static let _offerConditions = """
{
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    }
"""
    
    static let _faq = """
{
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    }
"""
    
    static let _consent = """
{
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    }
"""
    
    static let _application = """
{
      "id": 123456789,
      "status": "DRAFT"
    }
"""
    
    static let _offer = """
{
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
"""
    
    static let _source = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "theme": "DEFAULT",
    "header": {
      "title": "Кредитная карта",
      "subtitle": "«Все включено»"
    },
    "banner": {
      "background": "dict/getProductCatalogImage?image=products/pages/order-credit-card/landing/images/digital_card_landing_bg.png",
      "highlightedOfferConditions": [
        "Вам одобрена сумма 97 000 ₽",
        "Предложение действует до 30.04.2025"
      ]
    },
    "offerConditions": {
      "title": "Персональное предложение",
      "list": [
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Процентная ставка",
          "subTitle": "6,5 % годовых"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Срок льготного периода",
          "subTitle": "До 62 дней"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Стоимость обслуживания",
          "subTitle": "Бесплатно навсегда"
        },
        {
          "md5hash": "b6fa019f307d6a72951ab7268708aa15",
          "title": "Оформление",
          "subTitle": "В отделении Банка"
        }
      ]
    },
    "frequentlyAskedQuestions": {
      "title": "Часто задаваемые вопросы",
      "list": [
        {
          "title": "Как повторно подключить подписку?",
          "description": "тест"
        },
        {
          "title": "Как начисляются проценты?",
          "description": "тесттесттесттесттесттесттесттест"
        },
        {
          "title": "Какие условия бесплатного обслуживания?",
          "description": ""
        }
      ]
    },
    "consent": {
      "terms": "https://www.forabank.ru/dkbo/dkbo.pdf",
      "tariffs": "https://www.forabank.ru/tarify/",
      "creditHistoryRequest": "https://www.forabank.ru/user-upload/dok-dbo-fl/coglasie-na-zapros-v-bki.pdf"
    },
    "application": {
      "id": 123456789,
      "status": "DRAFT"
    },
    "offer": {
      "id": "123",
      "gracePeriod": "36",
      "tarifPlanRate": "69.99",
      "offerPeriodValidity": "2025-03-31",
      "offerLimitAmount": "10000.00",
      "tarifPlanName": "ТП1",
      "icon": "37baa2ff94fb468f65fa0ea4017bf44a"
    }
  }
}
"""
}
