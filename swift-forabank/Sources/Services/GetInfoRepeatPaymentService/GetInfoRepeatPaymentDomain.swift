//
//  GetInfoRepeatPaymentDomain.swift
//
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation

/// A namespace.
public enum GetInfoRepeatPaymentDomain {}

public extension GetInfoRepeatPaymentDomain {
    
    typealias Payload = GetInfoRepeatPayment
    typealias Result = Swift.Result<Payload, InfoPaymentError>
    typealias Completion = (Result) -> Void
    
    typealias Response = Swift.Result<(Data, HTTPURLResponse), Swift.Error>
    typealias ResponseCompletion = (Response) -> Void
    typealias PerformRequest = (URLRequest, @escaping ResponseCompletion) -> Void
    typealias MapResponse = (Data, HTTPURLResponse) -> Result
    
    enum InfoPaymentError: Error, Equatable {
        
        case connectivity
        case serverError(statusCode: Int, errorMessage: String)
    }
}

extension GetInfoRepeatPaymentDomain {
    
    public struct GetInfoRepeatPayment: Equatable {
        
        public let type: TransferType
        public let parameterList: [Transfer]
        public let productTemplate: ProductTemplate?
    
        public init(
            type: TransferType,
            parameterList: [Transfer],
            productTemplate: ProductTemplate?
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
        }
        
        public enum TransferType: String {
            
            case betweenTheir = "BETWEEN_THEIR"
            case contactAddressless = "CONTACT_ADDRESSLESS"
            case direct = "DIRECT"
            case externalEntity = "EXTERNAL_ENTITY"
            case externalIndivudual = "EXTERNAL_INDIVIDUAL"
            case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
            case insideBank = "INSIDE_BANK"
            case internet = "INTERNET"
            case mobile = "MOBILE"
            case otherBank = "OTHER_BANK"
            case sfp = "SFP"
            case transport = "TRANSPORT"
            case taxes = "TAX_AND_STATE_SERVICE"
        }
        
        public struct Transfer: Equatable {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            let comment: String?
            let puref: String?
            let payeeInternal: PayeeInternal?
            let payeeExternal: PayeeExternal?
            let additional: [Additional]?
            let mcc: String?

            public init(
                check: Bool,
                amount: Double,
                currencyAmount: String,
                payer: Payer,
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
            
            public init(
                transfer: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.Transfer
            ) {
                self.check = transfer.check
                self.amount = transfer.amount
                self.currencyAmount = transfer.currencyAmount
                self.payer = .init(payer: transfer.payer)
                self.comment = transfer.comment
                self.puref = transfer.puref
                self.payeeInternal = .init(payeeInternal: transfer.payeeInternal)
                self.payeeExternal = .init(payeeExternal: transfer.payeeExternal)
                self.additional = transfer.additional?.map({
                    .init(
                        fieldname: $0.fieldname,
                        fieldid: $0.fieldid,
                        fieldvalue: $0.fieldvalue
                    )
                })
                self.mcc = transfer.mcc
            }
            
            public struct PayeeInternal: Equatable {
                
                let accountId: Int?
                let accountNumber: String?
                let cardId: Int?
                let cardNumber: String?
                let phoneNumber: String?
                let productCustomName: String?
                
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
                
                public init(
                    payeeInternal: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.Transfer.PayeeInternal?
                ) {
                    self.accountId = payeeInternal?.accountId
                    self.accountNumber = payeeInternal?.accountNumber
                    self.cardId = payeeInternal?.cardId
                    self.cardNumber = payeeInternal?.cardNumber
                    self.phoneNumber = payeeInternal?.phoneNumber
                    self.productCustomName = payeeInternal?.productCustomName
                }
            }
            
            public struct PayeeExternal: Equatable {
                
                let inn: String?
                let kpp: String?
                let accountId: Int?
                let accountNumber: String
                let bankBIC: String?
                let cardId: Int?
                let cardNumber: String?
                let compilerStatus: String?
                let date: String?
                let name: String
                
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
                
                public init(
                    payeeExternal: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.Transfer.PayeeExternal?
                ) {
                    self.inn = payeeExternal?.inn
                    self.kpp = payeeExternal?.kpp
                    self.accountId = payeeExternal?.accountId
                    self.accountNumber = payeeExternal?.accountNumber ?? ""
                    self.bankBIC = payeeExternal?.bankBIC
                    self.cardId = payeeExternal?.cardId
                    self.cardNumber = payeeExternal?.cardNumber
                    self.compilerStatus = payeeExternal?.compilerStatus
                    self.date = payeeExternal?.date
                    self.name = payeeExternal?.name ?? ""
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
            
                let fieldname: String
                let fieldid: Int
                let fieldvalue: String
            }
            
            public struct Payer: Equatable {
                
                let cardId: Int
                let cardNumber: String?
                let accountId: Int?
                let accountNumber: String?
                let phoneNumber: String?
                let inn: String?
                
                public init(
                    cardId: Int,
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
                
                public init(
                    payer: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.Transfer.Payer
                ) {
                    self.cardId = payer.cardId
                    self.cardNumber = payer.cardNumber
                    self.accountId = payer.accountId
                    self.accountNumber = payer.accountNumber
                    self.phoneNumber = payer.phoneNumber
                    self.inn = payer.INN
                }
            }
        }
        
        public struct ProductTemplate: Equatable {
            
            let id: Int?
            let numberMask: String?
            let customName: String?
            let currency: String?
            let type: ProductType?
            let smallDesign: String?
            let paymentSystemImage: String?
            
            enum ProductType: Equatable {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
}
