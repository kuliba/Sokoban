//
//  ResponseMapper+mapCreateCreditCardLandingAndApplicationResponse.swift
//
//
//  Created by Igor Malyarov on 29.03.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
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

