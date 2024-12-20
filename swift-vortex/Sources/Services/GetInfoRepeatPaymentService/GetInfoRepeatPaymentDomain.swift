//
//  GetInfoRepeatPaymentDomain.swift
//
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation
import RemoteServices

/// A namespace.
public enum GetInfoRepeatPaymentDomain {}

public extension GetInfoRepeatPaymentDomain {
    
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    typealias Response = GetInfoRepeatPayment
    typealias Result = RemoteServices.ResponseMapper.MappingResult<Response>
    typealias Completion = (Result) -> Void
}

extension GetInfoRepeatPaymentDomain {
    
    public struct GetInfoRepeatPayment: Equatable {
        
        public let type: TransferType
        public let parameterList: [Transfer]
        public let productTemplate: ProductTemplate?
        public let paymentFlow: String?
    
        public init(
            type: TransferType,
            parameterList: [Transfer],
            productTemplate: ProductTemplate?,
            paymentFlow: String?
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
            self.paymentFlow = paymentFlow
        }
        
        public enum TransferType: Equatable {
            
            case addressingCash
            case addressless
            case betweenTheir
            case byPhone
            case charityService
            case contactAddressless
            case digitalWalletsService
            case direct
            case educationService
            case externalEntity
            case externalIndivudual
            case foreignCard
            case housingAndCommunalService
            case insideBank
            case internet
            case mobile
            case networkMarketingService
            case newDirect
            case newDirectAccount
            case newDirectCard
            case otherBank
            case repaymentLoansAndAccountsService
            case securityService
            case sfp
            case socialAndGamesService
            case taxes
            case transport
            case unknown
        }
        
        public struct Transfer: Equatable {
            
            let check: Bool
            public let amount: Double?
            let currencyAmount: String?
            public let payer: Payer?
            public let comment: String?
            public let puref: String?
            public let payeeInternal: PayeeInternal?
            public let payeeExternal: PayeeExternal?
            public let additional: [Additional]?
            let mcc: String?

            public init(
                check: Bool,
                amount: Double?,
                currencyAmount: String?,
                payer: Payer?,
                comment: String?,
                puref: String?,
                payeeInternal: PayeeInternal?,
                payeeExternal: PayeeExternal?,
                additional: [Additional]?,
                mcc: String?
            ) {
                self.check = check
                self.amount = amount
                self.currencyAmount = currencyAmount
                self.payer = payer
                self.comment = comment
                self.puref = puref
                self.payeeInternal = payeeInternal
                self.payeeExternal = payeeExternal
                self.additional = additional
                self.mcc = mcc
            }
            
            public struct PayeeInternal: Equatable {
                
                public let accountId: Int?
                public let accountNumber: String?
                public let cardId: Int?
                public let cardNumber: String?
                public let phoneNumber: String?
                public let productCustomName: String?
                
                public init(
                    accountId: Int?,
                    accountNumber: String?,
                    cardId: Int?,
                    cardNumber: String?,
                    phoneNumber: String?,
                    productCustomName: String?
                ) {
                    self.accountId = accountId
                    self.accountNumber = accountNumber
                    self.cardId = cardId
                    self.cardNumber = cardNumber
                    self.phoneNumber = phoneNumber
                    self.productCustomName = productCustomName
                }
            }
            
            public struct PayeeExternal: Equatable {
                
                public let inn: String?
                public let kpp: String?
                public let accountId: Int?
                public let accountNumber: String
                public let bankBIC: String?
                public let cardId: Int?
                public let cardNumber: String?
                public let compilerStatus: String?
                public let date: String?
                public let name: String
                
                public init(
                    inn: String?,
                    kpp: String?,
                    accountId: Int?,
                    accountNumber: String,
                    bankBIC: String?,
                    cardId: Int?,
                    cardNumber: String?,
                    compilerStatus: String?,
                    date: String?,
                    name: String
                ) {
                    self.inn = inn
                    self.kpp = kpp
                    self.accountId = accountId
                    self.accountNumber = accountNumber
                    self.bankBIC = bankBIC
                    self.cardId = cardId
                    self.cardNumber = cardNumber
                    self.compilerStatus = compilerStatus
                    self.date = date
                    self.name = name
                }
                
                public struct Tax: Equatable {
                    
                    let bcc: String?
                    let date: String?
                    let documentNumber: String?
                    let documentType: String?
                    let oktmo: String?
                    let period: String?
                    let reason: String?
                    let uin: String?
                    
                    public init(
                        bcc: String?,
                        date: String?,
                        documentNumber: String?,
                        documentType: String?,
                        oktmo: String?,
                        period: String?,
                        reason: String?,
                        uin: String?
                    ) {
                        self.bcc = bcc
                        self.date = date
                        self.documentNumber = documentNumber
                        self.documentType = documentType
                        self.oktmo = oktmo
                        self.period = period
                        self.reason = reason
                        self.uin = uin
                    }
                }
            }
            
            public struct Additional: Equatable {
            
                public let fieldname: String
                public let fieldid: Int
                public let fieldvalue: String
                
                public init(fieldname: String, fieldid: Int, fieldvalue: String) {
                    self.fieldname = fieldname
                    self.fieldid = fieldid
                    self.fieldvalue = fieldvalue
                }
            }
            
            public struct Payer: Equatable {
                
                public let cardId: Int?
                public let cardNumber: String?
                public let accountId: Int?
                public let accountNumber: String?
                public let phoneNumber: String?
                public let inn: String?
                
                public init(
                    cardId: Int?,
                    cardNumber: String?,
                    accountId: Int?,
                    accountNumber: String?,
                    phoneNumber: String?,
                    inn: String?
                ) {
                    self.cardId = cardId
                    self.cardNumber = cardNumber
                    self.accountId = accountId
                    self.accountNumber = accountNumber
                    self.phoneNumber = phoneNumber
                    self.inn = inn
                }
            }
        }
        
        public struct ProductTemplate: Equatable {
            
            public let id: Int?
            public let numberMask: String?
            public let customName: String?
            public let currency: String?
            public let type: ProductType?
            public let smallDesign: String?
            public let paymentSystemImage: String?
            
            public init(
                id: Int?,
                numberMask: String?,
                customName: String?,
                currency: String?,
                type: ProductType?,
                smallDesign: String?,
                paymentSystemImage: String?
            ) {
                self.id = id
                self.numberMask = numberMask
                self.customName = customName
                self.currency = currency
                self.type = type
                self.smallDesign = smallDesign
                self.paymentSystemImage = paymentSystemImage
            }
            
            public enum ProductType: Equatable {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
}
