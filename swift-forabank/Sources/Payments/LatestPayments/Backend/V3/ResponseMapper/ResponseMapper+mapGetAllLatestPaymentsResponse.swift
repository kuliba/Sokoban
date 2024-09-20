//
//  ResponseMapper+mapGetAllLatestPaymentsResponse.swift
//
//
//  Created by Igor Malyarov on 28.06.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetAllLatestPaymentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[LatestPayment]> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return map(
            data, httpURLResponse,
            dateDecodingStrategy: .formatted(dateFormatter),
            mapOrThrow: [LatestPayment].init
        )
    }
    
    struct LatestPaymentError: Error {}
}

// MARK: - Mapping

private extension Array where Element == ResponseMapper.LatestPayment {
    
    init(_ data: [ResponseMapper._Latest]) throws {
        
        guard !data.isEmpty else {
            
            throw ResponseMapper.LatestPaymentError()
        }
        
        self = data.compactMap(\.latest)
    }
}

private extension ResponseMapper._Latest {
    
    var latest: ResponseMapper.LatestPayment? {
        
        switch self {
        case let .service(service):
            return service.service.map { .service($0) }
            
        case let .withPhone(withPhone):
            return .withPhone(withPhone.withPhone)
        }
    }
}

private extension ResponseMapper._Latest._Service {
    
    var service: ResponseMapper.LatestPayment.Service? {
        
        guard let puref else { return nil }
        
        return .init(
            additionalItems: (additionalList ?? []).map(\.item),
            amount: amount,
            currency: currencyAmount,
            date: date,
            detail: paymentOperationDetailType?.detail,
            inn: inn,
            lpName: lpName,
            md5Hash: md5hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow?.flow,
            puref: puref,
            type: type.type
        )
    }
}

private extension ResponseMapper._Latest._WithPhone {
    
    var withPhone: ResponseMapper.LatestPayment.WithPhone {
        
        return .init(
            amount: amount?.value,
            bankID: bankId,
            bankName: bankName,
            currency: currencyAmount,
            date: date,
            detail: paymentOperationDetailType?.detail,
            md5Hash: md5hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow?.flow,
            phoneNumber: phoneNumber,
            puref: puref,
            type: type.type
        )
    }
}

private extension ResponseMapper._Latest._LatestType {
    
    var type: ResponseMapper.LatestPayment.LatestType {
        
        switch self {
        case .charity:                   return .charity
        case .country:                   return .country
        case .digitalWallets:            return .digitalWallets
        case .education:                 return .education
        case .internet:                  return .internet
        case .mobile:                    return .mobile
        case .networkMarketing:          return .networkMarketing
        case .outside:                   return .outside
        case .phone:                     return .phone
        case .repaymentLoansAndAccounts: return .repaymentLoansAndAccounts
        case .security:                  return .security
        case .service:                   return .service
        case .socialAndGames:            return .socialAndGames
        case .taxAndStateService:        return .taxAndStateService
        case .transport:                 return .transport
        }
    }
}

private extension ResponseMapper._Latest._Service._AdditionalItem {
    
    var item: ResponseMapper.LatestPayment.Service.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
}

private extension ResponseMapper._Latest._PaymentFlow {
    
    var flow: ResponseMapper.LatestPayment.PaymentFlow {
        
        switch self {
        case .mobile:              return .mobile
        case .qr:                  return .qr
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
}

private extension ResponseMapper._Latest._PaymentOperationDetailType {
    
    var detail: ResponseMapper.LatestPayment.PaymentOperationDetailType {
        
        switch self {
        case .account2Account:                  return .account2Account
        case .account2Card:                     return .account2Card
        case .account2Phone:                    return .account2Phone
        case .accountClose:                     return .accountClose
        case .addressingAccount:                return .addressingAccount
        case .addressingCash:                   return .addressingCash
        case .addressless:                      return .addressless
        case .bankDef:                          return .bankDef
        case .best2Pay:                         return .best2Pay
        case .card2Account:                     return .card2Account
        case .card2Card:                        return .card2Card
        case .card2Phone:                       return .card2Phone
        case .c2BPayment:                       return .c2BPayment
        case .c2BQrData:                        return .c2BQrData
        case .changeOutgoing:                   return .changeOutgoing
        case .charityService:                   return .charityService
        case .contactAddressing:                return .contactAddressing
        case .contactAddressless:               return .contactAddressless
        case .conversionAccount2Account:        return .conversionAccount2Account
        case .conversionAccount2Card:           return .conversionAccount2Card
        case .conversionAccount2Phone:          return .conversionAccount2Phone
        case .conversionCard2Account:           return .conversionCard2Account
        case .conversionCard2Card:              return .conversionCard2Card
        case .conversionCard2Phone:             return .conversionCard2Phone
        case .depositClose:                     return .depositClose
        case .depositOpen:                      return .depositOpen
        case .digitalWalletsService:            return .digitalWalletsService
        case .direct:                           return .direct
        case .educationService:                 return .educationService
        case .elecsnet:                         return .elecsnet
        case .external:                         return .external
        case .foreignCard:                      return .foreignCard
        case .housingAndCommunalService:        return .housingAndCommunalService
        case .interestDeposit:                  return .interestDeposit
        case .internet:                         return .internet
        case .me2MeCredit:                      return .me2MeCredit
        case .me2MeDebit:                       return .me2MeDebit
        case .mobile:                           return .mobile
        case .networkMarketingService:          return .networkMarketingService
        case .newDirect:                        return .newDirect
        case .newDirectAccount:                 return .newDirectAccount
        case .newDirectCard:                    return .newDirectCard
        case .oth:                              return .oth
        case .productPaymentCourier:            return .productPaymentCourier
        case .productPaymentOffice:             return .productPaymentOffice
        case .repaymentLoansAndAccountsService: return .repaymentLoansAndAccountsService
        case .returnOutgoing:                   return .returnOutgoing
        case .sberQrPayment:                    return .sberQrPayment
        case .securityService:                  return .securityService
        case .sfp:                              return .sfp
        case .socialAndGamesService:            return .socialAndGamesService
        case .taxAndStateService:               return .taxAndStateService
        case .transport:                        return .transport
        }
    }
}

// MARK: - DTO

private extension ResponseMapper {
    
    enum _Latest: Decodable {
        
        case service(_Service)
        case withPhone(_WithPhone)
        
        init(from decoder: Decoder) throws {
            
            do {
                self = try .service(_Service(from: decoder))
            } catch {
                self = try .withPhone(_WithPhone(from: decoder))
            }
        }
    }
}

private extension ResponseMapper._Latest {
    
    struct _Service: Decodable {
        
        let paymentDate: Date
        let date: Int
        let paymentOperationDetailType: _PaymentOperationDetailType?
        let type: _LatestType
        let currencyAmount: String?
        let puref: String?
        let md5hash: String?
        let name: String?
        let paymentFlow: _PaymentFlow?
        let amount: Decimal?
        let lpName: String?
        let inn: String?
        let additionalList: [_AdditionalItem]?
        
        struct _AdditionalItem: Decodable {
            
            let fieldName: String
            let fieldValue: String
            let fieldTitle: String?
            let svgImage: String?
            let recycle: String?
            let typeIdParameterList: String?
        }
    }
    
    struct _WithPhone: Decodable {
        
        let paymentDate: Date
        let date: Int
        let paymentOperationDetailType: _PaymentOperationDetailType?
        let type: _LatestType
        let currencyAmount: String?
        let puref: String?
        let md5hash: String?
        let name: String?
        let paymentFlow: _PaymentFlow?
        let phoneNumber: String?
        let bankName: String?
        let bankId: String?
        let amount: CustomDecimal?
    }
}

private extension ResponseMapper._Latest {
    
    enum _LatestType: String, Decodable {
        
        case charity
        case country
        case digitalWallets
        case education
        case internet
        case mobile
        case networkMarketing
        case outside
        case phone
        case repaymentLoansAndAccounts
        case security
        case service
        case socialAndGames
        case taxAndStateService
        case transport
    }
    
    enum _PaymentFlow: String, Decodable {
        
        case mobile              = "MOBILE"
        case qr                  = "QR"
        case standard            = "STANDARD_FLOW"
        case taxAndStateServices = "TAX_AND_STATE_SERVICE"
        case transport           = "TRANSPORT"
    }
    
    enum _PaymentOperationDetailType: String, Decodable {
        
        case account2Account = "ACCOUNT_2_ACCOUNT"
        case account2Card = "ACCOUNT_2_CARD"
        case account2Phone = "ACCOUNT_2_PHONE"
        case accountClose = "ACCOUNT_CLOSE"
        case addressingAccount = "ADDRESSING_ACCOUNT"
        case addressingCash = "ADDRESSING_CASH"
        case addressless = "ADDRESSLESS"
        case bankDef = "BANK_DEF"
        case best2Pay = "BEST2PAY"
        case card2Account = "CARD_2_ACCOUNT"
        case card2Card = "CARD_2_CARD"
        case card2Phone = "CARD_2_PHONE"
        case c2BPayment = "C2B_PAYMENT"
        case c2BQrData = "C2B_QR_DATA"
        case changeOutgoing = "CHANGE_OUTGOING"
        case charityService = "CHARITY_SERVICE"
        case contactAddressing = "CONTACT_ADDRESSING"
        case contactAddressless = "CONTACT_ADDRESSLESS"
        case conversionAccount2Account = "CONVERSION_ACCOUNT_2_ACCOUNT"
        case conversionAccount2Card = "CONVERSION_ACCOUNT_2_CARD"
        case conversionAccount2Phone = "CONVERSION_ACCOUNT_2_PHONE"
        case conversionCard2Account = "CONVERSION_CARD_2_ACCOUNT"
        case conversionCard2Card = "CONVERSION_CARD_2_CARD"
        case conversionCard2Phone = "CONVERSION_CARD_2_PHONE"
        case depositClose = "DEPOSIT_CLOSE"
        case depositOpen = "DEPOSIT_OPEN"
        case digitalWalletsService = "DIGITAL_WALLETS_SERVICE"
        case direct = "DIRECT"
        case educationService = "EDUCATION_SERVICE"
        case elecsnet = "ELECSNET"
        case external = "EXTERNAL"
        case foreignCard = "FOREIGN_CARD"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case interestDeposit = "INTEREST_DEPOSIT"
        case internet = "INTERNET"
        case me2MeCredit = "ME2ME_CREDIT"
        case me2MeDebit = "ME2ME_DEBIT"
        case mobile = "MOBILE"
        case networkMarketingService = "NETWORK_MARKETING_SERVICE"
        case newDirect = "NEW_DIRECT"
        case newDirectAccount = "NEW_DIRECT_ACCOUNT"
        case newDirectCard = "NEW_DIRECT_CARD"
        case oth = "OTH"
        case productPaymentCourier = "PRODUCT_PAYMENT_COURIER"
        case productPaymentOffice = "PRODUCT_PAYMENT_OFFICE"
        case repaymentLoansAndAccountsService = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
        case returnOutgoing = "RETURN_OUTGOING"
        case sberQrPayment = "SBER_QR_PAYMENT"
        case securityService = "SECURITY_SERVICE"
        case sfp = "SFP"
        case socialAndGamesService = "SOCIAL_AND_GAMES_SERVICE"
        case taxAndStateService = "TAX_AND_STATE_SERVICE"
        case transport = "TRANSPORT"
    }
}
