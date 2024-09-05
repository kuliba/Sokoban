//
//  ResponseMapper+mapGetPaymentTemplateListResponse.swift
//
//
//  Created by Igor Malyarov on 05.09.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetPaymentTemplateListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetPaymentTemplateListResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetPaymentTemplateListResponse.init)
    }
    
    enum GetPaymentTemplateListError: Error {
        
        case emptyCategoryList
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard !data.templateList.isEmpty else {
            
            throw ResponseMapper.GetPaymentTemplateListError.emptyCategoryList
        }
        
        self.init(
            serial: data.serial,
            templates: data.templateList.map(Template.init)
        )
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse.Template {
    
    init(_ template: ResponseMapper._Data._Template) {
        
        self.init(
            id: template.paymentTemplateId,
            group: template.groupName,
            inn: template.inn,
            md5Hash: template.md5hash,
            name: template.name,
            parameters: template.parameterList.map(Parameter.init),
            paymentFlow: template.paymentFlow.map { .init($0) },
            sort: template.sort,
            type: .init(template.type)
        )
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse.Template.PaymentFlow {
    
    init(_ flow: ResponseMapper._Data._Template._PaymentFlow) {
        
        switch flow {
        case .mobile:              self = .mobile
        case .qr:                  self = .qr
        case .standard:            self = .standard
        case .taxAndStateServices: self = .taxAndStateServices
        case .transport:           self = .transport
        }
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse.Template.TemplateType {
    
    init(_ type: ResponseMapper._Data._Template._TemplateType) {
        
        switch type {
        case .addressingCash:            self = .addressingCash
        case .addressless:               self = .addressless
        case .betweenTheir:              self = .betweenTheir
        case .byPhone:                   self = .byPhone
        case .contact:                   self = .contact
        case .direct:                    self = .direct
        case .externalEntity:            self = .externalEntity
        case .externalIndividual:        self = .externalIndividual
        case .housingAndCommunalService: self = .housingAndCommunalService
        case .insideBank:                self = .insideBank
        case .internet:                  self = .internet
        case .interestDeposit:           self = .interestDeposit
        case .mobile:                    self = .mobile
        case .newDirect:                 self = .newDirect
        case .newDirectCash:             self = .newDirectCash
        case .otherBank:                 self = .otherBank
        case .sfp:                       self = .sfp
        case .tax:                       self = .tax
        case .transport:                 self = .transport
        }
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter {
    
    init(_ parameter: ResponseMapper._Data._Template._Parameter) {
        
        self.init(
            amount: parameter.amount,
            check: parameter.check,
            currency: parameter.currencyAmount,
            payer: parameter.payer.map { .init($0) },
            comment: parameter.comment
        )
    }
}

private extension ResponseMapper.GetPaymentTemplateListResponse.Template.Parameter.Payer {
    
    init(_ payer: ResponseMapper._Data._Template._Parameter._Payer) {
        
        self.init(
            cardID: payer.cardId,
            cardNumber: payer.cardNumber,
            accountID: payer.accountId,
            accountNumber: payer.accountNumber,
            phoneNumber: payer.phoneNumber,
            inn: payer.INN
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String
        let templateList: [_Template]
    }
}

private extension ResponseMapper._Data {
    
    struct _Template: Decodable {
        
        let paymentTemplateId: Int
        let name: String
        let groupName: String
        let type: _TemplateType
        let sort: Int
        let parameterList: [_Parameter]
        let inn: String?
        let md5hash: String?
        let paymentFlow: _PaymentFlow?
    }
}

private extension ResponseMapper._Data._Template {
    
    enum _PaymentFlow: String, Decodable {
        
        case mobile              = "MOBILE"
        case qr                  = "QR"
        case standard            = "STANDARD_FLOW"
        case taxAndStateServices = "TAX_AND_STATE_SERVICE"
        case transport           = "TRANSPORT"
    }
    
    enum _TemplateType: String, Decodable {
        
        case addressingCash = "ADDRESSING_CASH"
        case addressless = "ADDRESSLESS"
        case betweenTheir = "BETWEEN_THEIR"
        case byPhone = "BY_PHONE"
        case contact = "CONTACT_ADDRESSLESS"
        case direct = "DIRECT"
        case externalEntity = "EXTERNAL_ENTITY"
        case externalIndividual = "EXTERNAL_INDIVIDUAL"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case insideBank = "INSIDE_BANK"
        case internet = "INTERNET"
        case interestDeposit = "INTEREST_DEPOSIT"
        case mobile = "MOBILE"
        case newDirect = "NEW_DIRECT"
        case newDirectCash = "NEW_DIRECT_CARD"
        case otherBank = "OTHER_BANK"
        case sfp = "SFP"
        case tax = "TAX_AND_STATE_SERVICE"
        case transport = "TRANSPORT"
    }
    
    struct _Parameter: Decodable {
        
        let check: Bool?
        let amount: Decimal?
        let currencyAmount: String?
        let payer: _Payer?
        let comment: String?
    }
}

private extension ResponseMapper._Data._Template._Parameter {
    
    struct _Payer: Decodable {
        
        let cardId: Int?
        let cardNumber: String?
        let accountId: Int?
        let accountNumber: String?
        let phoneNumber: String?
        let INN: String?
    }
}
