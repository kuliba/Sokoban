//
//  OperationDetailData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

struct OperationDetailData: Codable, Equatable {

    let oktmo: String?
    let account: String?
    let accountTitle: String?
    let amount: Double
    let billDate: String?
    let billNumber: String?
    let claimId: String
    let comment: String?
    let countryName: String?
    let currencyAmount: String
    let dateForDetail: String
    let division: String?
    let driverLicense: String?
    let externalTransferType: ExternalTransferType?
    let isForaBank: Bool?
    let isTrafficPoliceService: Bool
    let memberId: String?
    let operation: String?
    let payeeAccountId: Int?
    let payeeAccountNumber: String?
    let payeeAmount: Double?
    let payeeBankBIC: String?
    let payeeBankCorrAccount: String?
    let payeeBankName: String?
    let payeeCardId: Int?
    let payeeCardNumber: String?
    let payeeCurrency: String?
    let payeeFirstName: String?
    let payeeFullName: String?
    let payeeINN: String?
    let payeeKPP: String?
    let payeeMiddleName: String?
    let payeePhone: String?
    let payeeSurName: String?
    let payerAccountId: Int
    let payerAccountNumber: String
    let payerAddress: String
    let payerAmount: Double
    let payerCardId: Int?
    let payerCardNumber: String?
    let payerCurrency: String
    let payerDocument: String?
    let payerFee: Double
    let payerFirstName: String
    let payerFullName: String
    let payerINN: String?
    let payerMiddleName: String?
    let payerPhone: String?
    let payerSurName: String?
    let paymentOperationDetailId: Int
    let paymentTemplateId: Int?
    let period: String?
    let printFormType: PrintFormType
    let provider: String?
    let puref: String?
    let regCert: String?
    let requestDate: String
    let responseDate: String
    let returned: Bool?
    let transferDate: String
    let transferEnum: TransferEnum?
    let transferNumber: String?
    let transferReference: String?
    let cursivePayerAmount: String?
    let cursivePayeeAmount: String?
    let cursiveAmount: String?
    let serviceSelect: String?
    let serviceName: String?
    let merchantSubName: String?
    let merchantIcon: String?
    let operationStatus: OperationStatus?
    let shopLink: String?
    let payeeCheckAccount: String?
    let depositNumber: String?
    let depositDateOpen: String?
    let currencyRate: Double?
    let mcc: String?
    let printData: PrintMapData?
    
    enum ExternalTransferType: String, Codable, Unknownable {
        
        case entity = "ENTITY"
        case individual = "INDIVIDUAL"
        case unknown
    }
    
    enum OperationStatus: String, Codable, Unknownable {
        
        case complete = "COMPLETE"
        case inProgress = "IN_PROGRESS"
        case rejected = "REJECTED"
        case unknown
    }
    
    enum TransferEnum: String, Codable, Unknownable {
        
        case accountToAccount = "ACCOUNT_2_ACCOUNT"
        case accountToCard = "ACCOUNT_2_CARD"
        case accountToPhone = "ACCOUNT_2_PHONE"
        case bankDef = "BANK_DEF"
        case bestToPay = "BEST2PAY"
        case cardToAccount = "CARD_2_ACCOUNT"
        case cardToCard = "CARD_2_CARD"
        case cardToPhone = "CARD_2_PHONE"
        case changeOutgoing = "CHANGE_OUTGOING"
        case contactAddressing = "CONTACT_ADDRESSING"
        case contactAddressless = "CONTACT_ADDRESSLESS"
        case depositOpen = "DEPOSIT_OPEN"
        case direct = "DIRECT"
        case elecsnet = "ELECSNET"
        case external = "EXTERNAL"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case `internal` = "INTERNAL"
        case internet = "INTERNET"
        case meToMeCredit = "ME2ME_CREDIT"
        case meToMeDebit = "ME2ME_DEBIT"
        case mobile = "MOBILE"
        case oth = "OTH"
        case returnOutgoing = "RETURN_OUTGOING"
        case sfp = "SFP"
        case transport = "TRANSPORT"
        case conversionCardToCard = "CONVERSION_CARD_2_CARD"
        case conversionCardToAccount = "CONVERSION_CARD_2_ACCOUNT"
        case conversionCardToPhone = "CONVERSION_CARD_2_PHONE"
        case conversionAccountToCard = "CONVERSION_ACCOUNT_2_CARD"
        case conversionAccountToAccount = "CONVERSION_ACCOUNT_2_ACCOUNT"
        case conversionAccountToPhone = "CONVERSION_ACCOUNT_2_PHONE"
        case depositClose = "DEPOSIT_CLOSE"
        case accountClose = "ACCOUNT_CLOSE"
        case taxAndStateService = "TAX_AND_STATE_SERVICE"
        case ctbQrData = "C2B_QR_DATA"
        case ctbPayment = "C2B_PAYMENT"
        case interestDeposit = "INTEREST_DEPOSIT"
        case unknown
    }
    
    struct PrintMapData: Codable, Equatable {
        
        let claimId: String
        let requestDate: String
        let responseDate: String
        let transferDate: String
        let payerCardId: Int?
        let payerCardNumber: String?
        let payerAccountId: Int
        let payerAccountNumber: String
        let payerFullName: String
        let payerAddress: String
        let payerAmount: Double
        let cursivePayerAmount: String?
        let payerFee: Double
        let payerCurrency: String
        let payeeFullName: String?
        let payeePhone: String?
        let payeeBankName: String?
        let payeeAmount: Double?
        let cursivePayeeAmount: String?
        let payeeCurrency: String?
        let amount: Double
        let cursiveAmount: String?
        let currencyAmount: String
        let comment: String?
        let accountTitle: String?
        let account: String?
        let transferEnum: TransferEnum?
        let externalTransferType: ExternalTransferType?
        let isForaBank: Bool?
        let transferReference: String?
        let payerSurName: String?
        let payerFirstName: String
        let payerMiddleName: String?
        let payeeSurName: String?
        let payeeFirstName: String?
        let payeeMiddleName: String?
        let countryName: String?
        let payerDocument: String?
        let period: String?
        let provider: String?
        let payerPhone: String?
        let transferNumber: String?
        let payeeBankCorrAccount: String?
        let payeeCardNumber: String?
        let payeeCardId: Int?
        let payeeAccountNumber: String?
        let payeeAccountId: Int?
        let operation: String?
        let puref: String?
        let memberId: String?
        let driverLicense: String?
        let regCert: String?
        let billNumber: String?
        let billDate: String?
        let isTrafficPoliceService: Bool
        let division: String?
        let serviceSelect: String?
        let serviceName: String?
        let merchantSubName: String?
        let merchantIcon: String?
        let operationStatus: OperationStatus?
        let shopLink: String?
        let payeeCheckAccount: String?
        let depositNumber: String?
        let depositDateOpen: String?
        let currencyRate: Double?
        let payerINN: String?
        let payeeINN: String?
        let payeeKPP: String?
        let payeeBankBIC: String?
        let oktmo: String?
        let mcc: String?
    }
    
    enum CodingKeys : String, CodingKey {
        
        case oktmo = "OKTMO"
        case account
        case accountTitle
        case amount
        case billDate
        case billNumber
        case claimId
        case comment
        case countryName
        case currencyAmount
        case dateForDetail
        case division
        case driverLicense
        case externalTransferType
        case isForaBank
        case isTrafficPoliceService
        case memberId
        case operation
        case payeeAccountId
        case payeeAccountNumber
        case payeeAmount
        case payeeBankBIC
        case payeeBankCorrAccount
        case payeeBankName
        case payeeCardId
        case payeeCardNumber
        case payeeCurrency
        case payeeFirstName
        case payeeFullName
        case payeeINN
        case payeeKPP
        case payeeMiddleName
        case payeePhone
        case payeeSurName
        case payerAccountId
        case payerAccountNumber
        case payerAddress
        case payerAmount
        case payerCardId
        case payerCardNumber
        case payerCurrency
        case payerDocument
        case payerFee
        case payerFirstName
        case payerFullName
        case payerINN
        case payerMiddleName
        case payerPhone
        case payerSurName
        case paymentOperationDetailId
        case paymentTemplateId
        case period
        case printFormType
        case provider
        case puref
        case regCert
        case requestDate
        case responseDate
        case returned
        case transferDate
        case transferEnum
        case transferNumber
        case transferReference
        case cursivePayerAmount
        case cursivePayeeAmount
        case cursiveAmount
        case serviceSelect
        case serviceName
        case merchantSubName
        case merchantIcon
        case operationStatus
        case shopLink
        case payeeCheckAccount
        case depositNumber
        case depositDateOpen
        case currencyRate
        case printData = "printDataForOperationDetailResponse"
        case mcc = "MCC"
    }
}
