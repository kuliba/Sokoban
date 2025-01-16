//
//  LatestPayment.swift
//
//
//  Created by Igor Malyarov on 06.09.2024.
//

import Foundation
import RemoteServices
import Tagged

extension ResponseMapper {
    
    /// - Warning: `service` is hardcoded as `housingAndCommunalService`
    public enum LatestPayment: Equatable {
        
        case service(Service)
        case withPhone(WithPhone)
    }
}

extension ResponseMapper.LatestPayment {
    
    /// - Warning: `service` is hardcoded as `housingAndCommunalService`
    public struct Service: Equatable {
        
        public let additionalItems: [AdditionalItem]?
        public let amount: Decimal?
        public let currency: String?
        public let date: Int
        public let detail: PaymentOperationDetailType
        public let inn: String?
        public let lpName: String?
        public let md5Hash: String?
        public let name: String?
        public let paymentDate: Date
        public let paymentFlow: PaymentFlow?
        public let puref: String
        public let type: LatestType
        
        public init(
            additionalItems: [AdditionalItem]?,
            amount: Decimal?,
            currency: String?,
            date: Int,
            detail: PaymentOperationDetailType,
            inn: String?,
            lpName: String?,
            md5Hash: String?,
            name: String?,
            paymentDate: Date,
            paymentFlow: PaymentFlow?,
            puref: String,
            type: LatestType
        ) {
            self.additionalItems = additionalItems
            self.amount = amount
            self.currency = currency
            self.date = date
            self.detail = detail
            self.inn = inn
            self.lpName = lpName
            self.md5Hash = md5Hash
            self.name = name
            self.paymentDate = paymentDate
            self.paymentFlow = paymentFlow
            self.puref = puref
            self.type = type
        }
    }
    
    /// - Warning: `service` is hardcoded as `housingAndCommunalService`
    public struct WithPhone: Equatable {
        
        public let amount: Decimal?
        public let bankID: String?
        public let bankName: String?
        public let currency: String?
        public let date: Int
        public let detail: PaymentOperationDetailType?
        public let md5Hash: String?
        public let name: String?
        public let paymentDate: Date
        public let paymentFlow: PaymentFlow?
        public let phoneNumber: String
        public let puref: String?
        public let type: LatestType
        
        public init(
            amount: Decimal?,
            bankID: String?,
            bankName: String?,
            currency: String?,
            date: Int,
            detail: PaymentOperationDetailType?,
            md5Hash: String?,
            name: String?,
            paymentDate: Date,
            paymentFlow: PaymentFlow?,
            phoneNumber: String,
            puref: String?,
            type: LatestType
        ) {
            self.amount = amount
            self.bankID = bankID
            self.bankName = bankName
            self.currency = currency
            self.date = date
            self.detail = detail
            self.md5Hash = md5Hash
            self.name = name
            self.paymentDate = paymentDate
            self.paymentFlow = paymentFlow
            self.phoneNumber = phoneNumber
            self.puref = puref
            self.type = type
        }
    }
}

extension ResponseMapper.LatestPayment {
    
    /// - Warning: `service` is hardcoded as `housingAndCommunalService`
    public typealias LatestType = Tagged<_LatestType, String>
    public enum _LatestType {}
    
    public enum PaymentFlow: Equatable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
    
    public typealias PaymentOperationDetailType = Tagged<_PaymentOperationDetailType, String>
    public enum _PaymentOperationDetailType {}
}

extension ResponseMapper.LatestPayment.Service {
    
    public struct AdditionalItem: Equatable {
        
        public let fieldName: String
        public let fieldValue: String
        public let fieldTitle: String?
        public let svgImage: String?
        
        public init(
            fieldName: String,
            fieldValue: String,
            fieldTitle: String?,
            svgImage: String?
        ) {
            self.fieldName = fieldName
            self.fieldValue = fieldValue
            self.fieldTitle = fieldTitle
            self.svgImage = svgImage
        }
    }
}

public extension RemoteServices.ResponseMapper.LatestPayment.LatestType {

    static let charity: Self                       = "charity"
    static let country: Self                       = "country"
    static let digitalWallets: Self                = "digitalWallets"
    static let education: Self                     = "education"
    static let internet: Self                      = "internet"
    static let mobile: Self                        = "mobile"
    static let networkMarketing: Self              = "networkMarketing"
    static let outside: Self                       = "outside"
    static let phone: Self                         = "phone"
    static let repaymentLoansAndAccounts: Self     = "repaymentLoansAndAccounts"
    static let security: Self                      = "security"
    static let service: Self                       = "housingAndCommunalService"
    static let socialAndGames: Self                = "socialAndGames"
    static let taxAndStateService: Self            = "taxAndStateService"
    static let transport: Self                     = "transport"
}

public extension ResponseMapper.LatestPayment.PaymentOperationDetailType {
    
    static let account2Account: Self                     = "ACCOUNT_2_ACCOUNT"
    static let account2Card: Self                        = "ACCOUNT_2_CARD"
    static let account2Phone: Self                       = "ACCOUNT_2_PHONE"
    static let accountClose: Self                        = "ACCOUNT_CLOSE"
    static let addressingAccount: Self                   = "ADDRESSING_ACCOUNT"
    static let addressingCash: Self                      = "ADDRESSING_CASH"
    static let addressless: Self                         = "ADDRESSLESS"
    static let bankDef: Self                             = "BANK_DEF"
    static let best2Pay: Self                            = "BEST2PAY"
    static let card2Account: Self                        = "CARD_2_ACCOUNT"
    static let card2Card: Self                           = "CARD_2_CARD"
    static let card2Phone: Self                          = "CARD_2_PHONE"
    static let c2BPayment: Self                          = "C2B_PAYMENT"
    static let c2BQrData: Self                           = "C2B_QR_DATA"
    static let changeOutgoing: Self                      = "CHANGE_OUTGOING"
    static let charityService: Self                      = "CHARITY_SERVICE"
    static let contactAddressing: Self                   = "CONTACT_ADDRESSING"
    static let contactAddressless: Self                  = "CONTACT_ADDRESSLESS"
    static let conversionAccount2Account: Self           = "CONVERSION_ACCOUNT_2_ACCOUNT"
    static let conversionAccount2Card: Self              = "CONVERSION_ACCOUNT_2_CARD"
    static let conversionAccount2Phone: Self             = "CONVERSION_ACCOUNT_2_PHONE"
    static let conversionCard2Account: Self              = "CONVERSION_CARD_2_ACCOUNT"
    static let conversionCard2Card: Self                 = "CONVERSION_CARD_2_CARD"
    static let conversionCard2Phone: Self                = "CONVERSION_CARD_2_PHONE"
    static let depositClose: Self                        = "DEPOSIT_CLOSE"
    static let depositOpen: Self                         = "DEPOSIT_OPEN"
    static let digitalWalletsService: Self               = "DIGITAL_WALLETS_SERVICE"
    static let direct: Self                              = "DIRECT"
    static let educationService: Self                    = "EDUCATION_SERVICE"
    static let elecsnet: Self                            = "ELECSNET"
    static let external: Self                            = "EXTERNAL"
    static let foreignCard: Self                         = "FOREIGN_CARD"
    static let golden: Self                              = "GOLDEN_PAYMENT"
    static let housingAndCommunalService: Self           = "HOUSING_AND_COMMUNAL_SERVICE"
    static let interestDeposit: Self                     = "INTEREST_DEPOSIT"
    static let internet: Self                            = "INTERNET"
    static let me2MeCredit: Self                         = "ME2ME_CREDIT"
    static let me2MeDebit: Self                          = "ME2ME_DEBIT"
    static let mobile: Self                              = "MOBILE"
    static let networkMarketingService: Self             = "NETWORK_MARKETING_SERVICE"
    static let newDirect: Self                           = "NEW_DIRECT"
    static let newDirectAccount: Self                    = "NEW_DIRECT_ACCOUNT"
    static let newDirectCard: Self                       = "NEW_DIRECT_CARD"
    static let oth: Self                                 = "OTH"
    static let productPaymentCourier: Self               = "PRODUCT_PAYMENT_COURIER"
    static let productPaymentOffice: Self                = "PRODUCT_PAYMENT_OFFICE"
    static let repaymentLoansAndAccountsService: Self    = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
    static let returnOutgoing: Self                      = "RETURN_OUTGOING"
    static let sberQrPayment: Self                       = "SBER_QR_PAYMENT"
    static let securityService: Self                     = "SECURITY_SERVICE"
    static let sfp: Self                                 = "SFP"
    static let socialAndGamesService: Self               = "SOCIAL_AND_GAMES_SERVICE"
    static let taxAndStateService: Self                  = "TAX_AND_STATE_SERVICE"
    static let transport: Self                           = "TRANSPORT"
    static let insuranceService: Self                    = "INSURANCE_SERVICE"
    static let journeyServices: Self                     = "JOURNEY_SERVICE"
}
