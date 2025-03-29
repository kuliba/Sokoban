//
//  ResponseMapper+CreateCreditCardLandingAndApplication.swift
//
//
//  Created by Igor Malyarov on 29.03.2025.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateCreditCardLandingAndApplication: Equatable {
        
        public let application: Application
        public let banner: Banner
        public let consent: Consent
        public let faq: FAQ
        public let header: Header?
        public let offer: Offer
        public let offerConditions: OfferConditions
        public let theme: String
        
        public init(
            application: Application,
            banner: Banner,
            consent: Consent,
            faq: FAQ,
            header: Header?,
            offer: Offer,
            offerConditions: OfferConditions,
            theme: String
        ) {
            self.application = application
            self.banner = banner
            self.consent = consent
            self.faq = faq
            self.header = header
            self.offer = offer
            self.offerConditions = offerConditions
            self.theme = theme
        }
    }
}

extension ResponseMapper.CreateCreditCardLandingAndApplication {
    
    public struct Application: Equatable {
        
        public let id: Int
        public let status: String
        
        public init(
            id: Int,
            status: String
        ) {
            self.id = id
            self.status = status
        }
    }
    
    public struct Banner: Equatable {
        
        public let background: String
        public let conditions: [String]
        
        public init(
            background: String,
            conditions: [String]
        ) {
            self.background = background
            self.conditions = conditions
        }
    }
    
    public struct Consent: Equatable {
        
        public let terms: String
        public let tariffs: String
        public let creditHistoryRequest: String
        
        public init(
            terms: String,
            tariffs: String,
            creditHistoryRequest: String
        ) {
            self.terms = terms
            self.tariffs = tariffs
            self.creditHistoryRequest = creditHistoryRequest
        }
    }
    
    public struct FAQ: Equatable {
        
        public let title: String
        public let list: [Item]
        
        public init(
            title: String,
            list: [Item]
        ) {
            self.title = title
            self.list = list
        }
        
        public struct Item: Equatable {
            
            public let title: String
            public let description: String
            
            public init(
                title: String,
                description: String
            ) {
                self.title = title
                self.description = description
            }
        }
    }
    
    public struct Header: Equatable {
        
        public let title: String
        public let subtitle: String
        
        public init(
            title: String,
            subtitle: String
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public struct Offer: Equatable {
        
        public let id: String
        public let gracePeriod: String
        public let tarifPlanRate: String
        public let offerPeriodValidity: String
        public let offerLimitAmount: String
        public let tarifPlanName: String
        public let icon: String
        
        public init(
            id: String,
            gracePeriod: String,
            tarifPlanRate: String,
            offerPeriodValidity: String,
            offerLimitAmount: String,
            tarifPlanName: String,
            icon: String
        ) {
            self.id = id
            self.gracePeriod = gracePeriod
            self.tarifPlanRate = tarifPlanRate
            self.offerPeriodValidity = offerPeriodValidity
            self.offerLimitAmount = offerLimitAmount
            self.tarifPlanName = tarifPlanName
            self.icon = icon
        }
    }
    
    public struct OfferConditions: Equatable {
        
        public let title: String
        // TODO: improve with non-empty
        public let list: [Condition]
        
        public init(
            title: String,
            list: [Condition]
        ) {
            self.title = title
            self.list = list
        }
        
        public struct Condition: Equatable {
            
            public let md5hash: String
            public let title: String
            public let subtitle: String
            
            public init(
                md5hash: String,
                title: String,
                subtitle: String
            ) {
                self.md5hash = md5hash
                self.title = title
                self.subtitle = subtitle
            }
        }
    }
}

