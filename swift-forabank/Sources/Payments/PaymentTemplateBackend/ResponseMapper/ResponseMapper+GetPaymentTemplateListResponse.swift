//
//  ResponseMapper+mapGetPaymentTemplateListResponse.swift
//
//
//  Created by Igor Malyarov on 05.09.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct GetPaymentTemplateListResponse: Equatable {
        
        public let serial: String
        public let templates: [Template]
        
        public init(
            serial: String,
            templates: [Template]
        ) {
            self.serial = serial
            self.templates = templates
        }
    }
}

extension ResponseMapper.GetPaymentTemplateListResponse {
    
    public struct Template: Equatable {
        
        public let id: Int
        public let group: String
        public let name: String
        public let parameters: [Parameter]
        public let sort: Int
        public let type: TemplateType
        
        public init(
            id: Int,
            group: String,
            name: String,
            parameters: [Parameter],
            sort: Int,
            type: TemplateType
        ) {
            self.id = id
            self.group = group
            self.name = name
            self.parameters = parameters
            self.sort = sort
            self.type = type
        }
    }
}

extension ResponseMapper.GetPaymentTemplateListResponse.Template {
    
    public enum TemplateType: Equatable {
        
        case addressingCash
        case addressless
        case betweenTheir
        case byPhone
        case contact
        case direct
        case externalEntity
        case externalIndividual
        case housingAndCommunalService
        case insideBank
        case internet
        case interestDeposit
        case mobile
        case newDirect
        case newDirectCash
        case otherBank
        case sfp
        case tax
        case transport
    }
    
    public struct Parameter: Equatable {
        
        let amount: Decimal?
        let check: Bool?
        let currency: String?
        let payer: Payer?
        let comment: String?
        
        public init(
            amount: Decimal?,
            check: Bool?,
            currency: String?,
            payer: Payer?,
            comment: String?
        ) {
            self.amount = amount
            self.check = check
            self.currency = currency
            self.payer = payer
            self.comment = comment
        }
    }
}

extension ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter {
    
    public struct Payer: Equatable {
        
        let cardID: Int?
        let cardNumber: String?
        let accountID: Int?
        let accountNumber: String?
        let phoneNumber: String?
        let inn: String?
        
        public init(
            cardID: Int?,
            cardNumber: String?,
            accountID: Int?,
            accountNumber: String?,
            phoneNumber: String?,
            inn: String?
        ) {
            self.cardID = cardID
            self.cardNumber = cardNumber
            self.accountID = accountID
            self.accountNumber = accountNumber
            self.phoneNumber = phoneNumber
            self.inn = inn
        }
    }
}
