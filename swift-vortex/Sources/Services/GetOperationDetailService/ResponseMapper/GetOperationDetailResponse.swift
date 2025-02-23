//
//  GetOperationDetailResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct GetOperationDetailResponse: Equatable {
        
        public let account: String?
        public let accountTitle: String?
        public let amount: Decimal?
        public let billDate: String?
        public let billNumber: String?
        public let cityName: String?
        public let claimID: String
        public let comment: String?
        public let countryName: String?
        public let currencyAmount: String?
        public let currencyRate: Int?
        public let cursiveAmount: String?
        public let cursivePayeeAmount: String?
        public let cursivePayerAmount: String?
        public let dateForDetail: String?
        public let depositDateOpen: String?
        public let depositNumber: String?
        public let division: String?
        public let driverLicense: String?
        public let externalTransferType: String?
        public let isForaBank: Bool?
        public let isTrafficPoliceService: Bool?
        public let MCC: String?
        public let memberID: String?
        public let merchantIcon: String?
        public let merchantSubName: String?
        public let OKTMO: String?
        public let operation: String?
        public let operationStatus: String?
        public let payeeAccountID: Int?
        public let payeeAccountNumber: String?
        public let payeeAmount: Int?
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
        public let payerAccountID: Int?
        public let payerAccountNumber: String?
        public let payerAddress: String?
        public let payerAmount: Int?
        public let payerCardID: Int?
        public let payerCardNumber: String?
        public let payerCurrency: String?
        public let payerDocument: String?
        public let payerFee: Int?
        public let payerFirstName: String?
        public let payerFullName: String?
        public let payerINN: String?
        public let payerMiddleName: String?
        public let payerPhone: String?
        public let payerSurName: String?
        public let paymentMethod: String?
        public let paymentOperationDetailID: Int?
        public let paymentTemplateID: Int?
        public let period: String?
        public let printFormType: String?
        public let provider: String?
        public let puref: String?
        public let regCert: String?
        public let requestDate: String?
        public let responseDate: String?
        public let returned: Bool?
        public let serviceName: String?
        public let serviceSelect: String?
        public let shopLink: String?
        public let transferDate: String?
        public let transferEnum: String?
        public let transferNumber: String?
        public let transferReference: String?
        public let trnPickupPointName: String?
        
        public init(account: String?, accountTitle: String?, amount: Decimal?, billDate: String?, billNumber: String?, cityName: String?, claimID: String, comment: String?, countryName: String?, currencyAmount: String?, currencyRate: Int?, cursiveAmount: String?, cursivePayeeAmount: String?, cursivePayerAmount: String?, dateForDetail: String?, depositDateOpen: String?, depositNumber: String?, division: String?, driverLicense: String?, externalTransferType: String?, isForaBank: Bool?, isTrafficPoliceService: Bool?, MCC: String?, memberID: String?, merchantIcon: String?, merchantSubName: String?, OKTMO: String?, operation: String?, operationStatus: String?, payeeAccountID: Int?, payeeAccountNumber: String?, payeeAmount: Int?, payeeBankBIC: String?, payeeBankCorrAccount: String?, payeeBankName: String?, payeeCardID: Int?, payeeCardNumber: String?, payeeCheckAccount: String?, payeeCurrency: String?, payeeFirstName: String?, payeeFullName: String?, payeeINN: String?, payeeKPP: String?, payeeMiddleName: String?, payeePhone: String?, payeeSurName: String?, payerAccountID: Int?, payerAccountNumber: String?, payerAddress: String?, payerAmount: Int?, payerCardID: Int?, payerCardNumber: String?, payerCurrency: String?, payerDocument: String?, payerFee: Int?, payerFirstName: String?, payerFullName: String?, payerINN: String?, payerMiddleName: String?, payerPhone: String?, payerSurName: String?, paymentMethod: String?, paymentOperationDetailID: Int?, paymentTemplateID: Int?, period: String?, printFormType: String?, provider: String?, puref: String?, regCert: String?, requestDate: String?, responseDate: String?, returned: Bool?, serviceName: String?, serviceSelect: String?, shopLink: String?, transferDate: String?, transferEnum: String?, transferNumber: String?, transferReference: String?, trnPickupPointName: String?) {
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
            self.cursivePayeeAmount = cursivePayeeAmount
            self.cursivePayerAmount = cursivePayerAmount
            self.dateForDetail = dateForDetail
            self.depositDateOpen = depositDateOpen
            self.depositNumber = depositNumber
            self.division = division
            self.driverLicense = driverLicense
            self.externalTransferType = externalTransferType
            self.isForaBank = isForaBank
            self.isTrafficPoliceService = isTrafficPoliceService
            self.MCC = MCC
            self.memberID = memberID
            self.merchantIcon = merchantIcon
            self.merchantSubName = merchantSubName
            self.OKTMO = OKTMO
            self.operation = operation
            self.operationStatus = operationStatus
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
            self.serviceName = serviceName
            self.serviceSelect = serviceSelect
            self.shopLink = shopLink
            self.transferDate = transferDate
            self.transferEnum = transferEnum
            self.transferNumber = transferNumber
            self.transferReference = transferReference
            self.trnPickupPointName = trnPickupPointName
        }
    }
}
