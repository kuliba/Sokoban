//
//  LatestPayment.swift
//
//
//  Created by Igor Malyarov on 06.09.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public enum LatestPayment: Equatable {
        
        case service(Service)
        case withPhone(WithPhone)
    }
}

extension ResponseMapper.LatestPayment {
    
    public struct Service: Equatable {
        
        public let additionalItems: [AdditionalItem]?
        public let amount: Decimal?
        public let currency: String?
        public let date: Int
        public let detail: PaymentOperationDetailType?
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
            detail: PaymentOperationDetailType?,
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
        public let phoneNumber: String?
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
            phoneNumber: String?,
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
    
    public enum LatestType: Equatable {
        
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
    
    public enum PaymentFlow: Equatable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
    
    public enum PaymentOperationDetailType: Equatable {
        
        case account2Account
        case account2Card
        case account2Phone
        case accountClose
        case addressingAccount
        case addressingCash
        case addressless
        case bankDef
        case best2Pay
        case card2Account
        case card2Card
        case card2Phone
        case c2BPayment
        case c2BQrData
        case changeOutgoing
        case charityService
        case contactAddressing
        case contactAddressless
        case conversionAccount2Account
        case conversionAccount2Card
        case conversionAccount2Phone
        case conversionCard2Account
        case conversionCard2Card
        case conversionCard2Phone
        case depositClose
        case depositOpen
        case digitalWalletsService
        case direct
        case educationService
        case elecsnet
        case external
        case foreignCard
        case housingAndCommunalService
        case interestDeposit
        case internet
        case me2MeCredit
        case me2MeDebit
        case mobile
        case networkMarketingService
        case newDirect
        case newDirectAccount
        case newDirectCard
        case oth
        case productPaymentCourier
        case productPaymentOffice
        case repaymentLoansAndAccountsService
        case returnOutgoing
        case sberQrPayment
        case securityService
        case sfp
        case socialAndGamesService
        case taxAndStateService
        case transport
    }
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
