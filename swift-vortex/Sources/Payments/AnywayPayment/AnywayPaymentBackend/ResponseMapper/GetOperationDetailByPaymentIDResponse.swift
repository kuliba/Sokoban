//
//  GetOperationDetailByPaymentIDResponse.swift
//
//
//  Created by Igor Malyarov on 26.03.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    struct GetOperationDetailByPaymentIDResponse: Equatable {
        
        public let account: String?
        public let accountTitle: String?
        public let amount: Decimal
        public let billDate: String?
        public let billNumber: String?
        public let cityName: String?
        public let claimID: String
        public let comment: String?
        public let countryName: String?
        public let currencyAmount: String?
        public let currencyRate: Decimal?
        public let cursiveAmount: String?
        public let cursivePayerAmount: String?
        public let cursivePayeeAmount: String?
        public let dateForDetail: String
        public let depositDateOpen: String?
        public let depositNumber: String?
        public let division: String?
        public let driverLicense: String?
        public let externalTransferType: ExternalTransferType?
        public let isForaBank: Bool?
        public let isTrafficPoliceService: Bool
        public let mcc: String?
        public let memberID: String?
        public let merchantIcon: String?
        public let merchantSubName: String?
        public let operation: String?
        public let operationStatus: OperationStatus?
        public let oktmo: String?
        public let payeeAccountID: Int?
        public let payeeAccountNumber: String?
        public let payeeAmount: Decimal?
        public let payeeBankBIC: String?
        public let payeeBankCorrAccount: String?
        public let payeeBankName: String?
        public let payeeCardID: Int?
        public let payeeCardNumber: String?
        public let payeeCheckAccount: String?
        public let payeeCurrency: String?
        public let payeeFirstName: String?
        public let payeeFullName: String?
        public let payeeINN: String?
        public let payeeKPP: String?
        public let payeeMiddleName: String?
        public let payeePhone: String?
        public let payeeSurName: String?
        public let payerAccountID: Int
        public let payerAccountNumber: String
        public let payerAddress: String
        public let payerAmount: Decimal
        public let payerCardID: Int?
        public let payerCardNumber: String?
        public let payerCurrency: String
        public let payerDocument: String?
        public let payerFee: Decimal
        public let payerFirstName: String
        public let payerFullName: String
        public let payerINN: String?
        public let payerMiddleName: String?
        public let payerPhone: String?
        public let payerSurName: String?
        public let paymentMethod: PaymentMethod?
        public let paymentOperationDetailID: Int
        public let paymentTemplateID: Int?
        public let period: String?
        public let printFormType: PrintFormType
        public let provider: String?
        public let puref: String?
        public let regCert: String?
        public let requestDate: String
        public let responseDate: String
        public let returned: Bool?
        public let serviceSelect: String?
        public let serviceName: String?
        public let shopLink: String?
        public let transfer: Transfer?
        public let transferDate: String
        public let transferNumber: String?
        public let transferReference: String?
        public let trnPickupPointName: String?
        
        public init(account: String? = nil, accountTitle: String? = nil, amount: Decimal, billDate: String? = nil, billNumber: String? = nil, cityName: String? = nil, claimID: String, comment: String? = nil, countryName: String? = nil, currencyAmount: String? = nil, currencyRate: Decimal? = nil, cursiveAmount: String? = nil, cursivePayerAmount: String? = nil, cursivePayeeAmount: String? = nil, dateForDetail: String, depositDateOpen: String? = nil, depositNumber: String? = nil, division: String? = nil, driverLicense: String? = nil, externalTransferType: ExternalTransferType? = nil, isForaBank: Bool? = nil, isTrafficPoliceService: Bool, mcc: String? = nil, memberID: String? = nil, merchantIcon: String? = nil, merchantSubName: String? = nil, operation: String? = nil, operationStatus: OperationStatus? = nil, oktmo: String? = nil, payeeAccountID: Int? = nil, payeeAccountNumber: String? = nil, payeeAmount: Decimal? = nil, payeeBankBIC: String? = nil, payeeBankCorrAccount: String? = nil, payeeBankName: String? = nil, payeeCardID: Int? = nil, payeeCardNumber: String? = nil, payeeCheckAccount: String? = nil, payeeCurrency: String? = nil, payeeFirstName: String? = nil, payeeFullName: String? = nil, payeeINN: String? = nil, payeeKPP: String? = nil, payeeMiddleName: String? = nil, payeePhone: String? = nil, payeeSurName: String? = nil, payerAccountID: Int, payerAccountNumber: String, payerAddress: String, payerAmount: Decimal, payerCardID: Int? = nil, payerCardNumber: String? = nil, payerCurrency: String, payerDocument: String? = nil, payerFee: Decimal, payerFirstName: String, payerFullName: String, payerINN: String? = nil, payerMiddleName: String? = nil, payerPhone: String? = nil, payerSurName: String? = nil, paymentMethod: PaymentMethod? = nil, paymentOperationDetailID: Int, paymentTemplateID: Int? = nil, period: String? = nil, printFormType: PrintFormType, provider: String? = nil, puref: String? = nil, regCert: String? = nil, requestDate: String, responseDate: String, returned: Bool? = nil, serviceSelect: String? = nil, serviceName: String? = nil, shopLink: String? = nil, transfer: Transfer? = nil, transferDate: String, transferNumber: String? = nil, transferReference: String? = nil, trnPickupPointName: String? = nil
        ) {
            self.account = account
            self.accountTitle = accountTitle
            self.amount = amount
            self.billDate = billDate
            self.billNumber = billNumber
            self.cityName = cityName
            self.claimID = claimID
            self.comment = comment
            self.countryName = countryName
            self.currencyAmount = currencyAmount
            self.currencyRate = currencyRate
            self.cursiveAmount = cursiveAmount
            self.cursivePayerAmount = cursivePayerAmount
            self.cursivePayeeAmount = cursivePayeeAmount
            self.dateForDetail = dateForDetail
            self.depositDateOpen = depositDateOpen
            self.depositNumber = depositNumber
            self.division = division
            self.driverLicense = driverLicense
            self.externalTransferType = externalTransferType
            self.isForaBank = isForaBank
            self.isTrafficPoliceService = isTrafficPoliceService
            self.mcc = mcc
            self.memberID = memberID
            self.merchantIcon = merchantIcon
            self.merchantSubName = merchantSubName
            self.operation = operation
            self.operationStatus = operationStatus
            self.oktmo = oktmo
            self.payeeAccountID = payeeAccountID
            self.payeeAccountNumber = payeeAccountNumber
            self.payeeAmount = payeeAmount
            self.payeeBankBIC = payeeBankBIC
            self.payeeBankCorrAccount = payeeBankCorrAccount
            self.payeeBankName = payeeBankName
            self.payeeCardID = payeeCardID
            self.payeeCardNumber = payeeCardNumber
            self.payeeCheckAccount = payeeCheckAccount
            self.payeeCurrency = payeeCurrency
            self.payeeFirstName = payeeFirstName
            self.payeeFullName = payeeFullName
            self.payeeINN = payeeINN
            self.payeeKPP = payeeKPP
            self.payeeMiddleName = payeeMiddleName
            self.payeePhone = payeePhone
            self.payeeSurName = payeeSurName
            self.payerAccountID = payerAccountID
            self.payerAccountNumber = payerAccountNumber
            self.payerAddress = payerAddress
            self.payerAmount = payerAmount
            self.payerCardID = payerCardID
            self.payerCardNumber = payerCardNumber
            self.payerCurrency = payerCurrency
            self.payerDocument = payerDocument
            self.payerFee = payerFee
            self.payerFirstName = payerFirstName
            self.payerFullName = payerFullName
            self.payerINN = payerINN
            self.payerMiddleName = payerMiddleName
            self.payerPhone = payerPhone
            self.payerSurName = payerSurName
            self.paymentMethod = paymentMethod
            self.paymentOperationDetailID = paymentOperationDetailID
            self.paymentTemplateID = paymentTemplateID
            self.period = period
            self.printFormType = printFormType
            self.provider = provider
            self.puref = puref
            self.regCert = regCert
            self.requestDate = requestDate
            self.responseDate = responseDate
            self.returned = returned
            self.serviceSelect = serviceSelect
            self.serviceName = serviceName
            self.shopLink = shopLink
            self.transfer = transfer
            self.transferDate = transferDate
            self.transferNumber = transferNumber
            self.transferReference = transferReference
            self.trnPickupPointName = trnPickupPointName
        }
    }
}

public extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    enum ExternalTransferType: Equatable {
        
        case entity, individual
    }
    
    enum OperationStatus: Equatable {
        
        case complete, inProgress, rejected
    }
    
    enum PrintFormType: Equatable {
        
        case addressing_cash
        case addressless
        case c2b
        case changeOutgoing
        case closeAccount
        case closeDeposit
        case contactAddressless
        case direct
        case external
        case housingAndCommunalService
        case `internal`
        case internet
        case mobile
        case newDirect
        case returnOutgoing
        case sberQR
        case sbp
        case sticker
        case taxAndStateService
        case transport
    }
    
    enum PaymentMethod: Equatable {
        
        case cash, cashless
    }
    
    enum Transfer: Equatable {
        
        case accountClose
        case accountToAccount
        case accountToCard
        case accountToPhone
        case bankDef
        case bestToPay
        case c2bPayment
        case c2bQrData
        case cardToAccount
        case cardToCard
        case cardToPhone
        case changeOutgoing
        case contactAddressing
        case contactAddressingCash
        case contactAddressless
        case conversionAccountToAccount
        case conversionAccountToCard
        case conversionAccountToPhone
        case conversionCardToAccount
        case conversionCardToCard
        case conversionCardToPhone
        case depositClose
        case depositOpen
        case direct
        case elecsnet
        case external
        case housingAndCommunalService
        case interestDeposit
        case `internal`
        case internet
        case meToMeCredit
        case meToMeDebit
        case mobile
        case other
        case productPaymentCourier
        case productPaymentOffice
        case returnOutgoing
        case sberQRPayment
        case sfp
        case taxAndStateService
        case transport
    }
}
