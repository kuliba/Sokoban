//
//  GetOperationDetailByPaymentIDResponse.swift
//
//
//  Created by Igor Malyarov on 26.03.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct GetOperationDetailByPaymentIDResponse: Equatable {
        
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
        public let cursivePayeeAmount: String?
        public let cursivePayerAmount: String?
        public let dateForDetail: String
        public let dateN: String?
        public let depositDateOpen: String?
        public let depositNumber: String?
        public let discount: String?
        public let discountExpiry: String?
        public let division: String?
        public let documentNumber: String?
        public let driverLicense: String?
        public let externalTransferType: ExternalTransferType?
        public let formattedAmount: String?
        public let isForaBank: Bool?
        public let isTrafficPoliceService: Bool
        public let legalAct: String?
        public let mcc: String?
        public let memberID: String?
        public let merchantIcon: String?
        public let merchantSubName: String?
        public let oktmo: String?
        public let operation: String?
        public let operationCategory: String?
        public let operationStatus: OperationStatus?
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
        public let paymentFlow: String?
        public let paymentMethod: PaymentMethod?
        public let paymentOperationDetailID: Int
        public let paymentTemplateID: Int?
        public let paymentTerm: String?
        public let period: String?
        public let printFormType: PrintFormType
        public let provider: String?
        public let puref: String?
        public let realPayerFIO: String?
        public let realPayerINN: String?
        public let realPayerKPP: String?
        public let regCert: String?
        public let requestDate: String
        public let responseDate: String
        public let returned: Bool?
        public let serviceName: String?
        public let serviceSelect: String?
        public let shopLink: String?
        public let supplierBillID: String?
        public let transAmm: Decimal?
        public let transfer: Transfer?
        public let transferDate: String
        public let transferNumber: String?
        public let transferReference: String?
        public let trnPickupPointName: String?
        public let upno: String?
        
        public init(
            account: String?,
            accountTitle: String?,
            amount: Decimal,
            billDate: String?,
            billNumber: String?,
            cityName: String?,
            claimID: String,
            comment: String?,
            countryName: String?,
            currencyAmount: String?,
            currencyRate: Decimal?,
            cursiveAmount: String?,
            cursivePayeeAmount: String?,
            cursivePayerAmount: String?,
            dateForDetail: String,
            dateN: String?,
            depositDateOpen: String?,
            depositNumber: String?,
            discount: String?,
            discountExpiry: String?,
            division: String?,
            documentNumber: String?,
            driverLicense: String?,
            externalTransferType: ExternalTransferType?,
            formattedAmount: String?,
            isForaBank: Bool?,
            isTrafficPoliceService: Bool,
            legalAct: String?,
            mcc: String?,
            memberID: String?,
            merchantIcon: String?,
            merchantSubName: String?,
            oktmo: String?,
            operation: String?,
            operationCategory: String?,
            operationStatus: OperationStatus?,
            payeeAccountID: Int?,
            payeeAccountNumber: String?,
            payeeAmount: Decimal?,
            payeeBankBIC: String?,
            payeeBankCorrAccount: String?,
            payeeBankName: String?,
            payeeCardID: Int?,
            payeeCardNumber: String?,
            payeeCheckAccount: String?,
            payeeCurrency: String?,
            payeeFirstName: String?,
            payeeFullName: String?,
            payeeINN: String?,
            payeeKPP: String?,
            payeeMiddleName: String?,
            payeePhone: String?,
            payeeSurName: String?,
            payerAccountID: Int,
            payerAccountNumber: String,
            payerAddress: String,
            payerAmount: Decimal,
            payerCardID: Int?,
            payerCardNumber: String?,
            payerCurrency: String,
            payerDocument: String?,
            payerFee: Decimal,
            payerFirstName: String,
            payerFullName: String,
            payerINN: String?,
            payerMiddleName: String?,
            payerPhone: String?,
            payerSurName: String?,
            paymentFlow: String?,
            paymentMethod: PaymentMethod?,
            paymentOperationDetailID: Int,
            paymentTemplateID: Int?,
            paymentTerm: String?,
            period: String?,
            printFormType: PrintFormType,
            provider: String?,
            puref: String?,
            realPayerFIO: String?,
            realPayerINN: String?,
            realPayerKPP: String?,
            regCert: String?,
            requestDate: String,
            responseDate: String,
            returned: Bool?,
            serviceName: String?,
            serviceSelect: String?,
            shopLink: String?,
            supplierBillID: String?,
            transAmm: Decimal?,
            transfer: Transfer?,
            transferDate: String,
            transferNumber: String?,
            transferReference: String?,
            trnPickupPointName: String?,
            upno: String?
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
            self.cursivePayeeAmount = cursivePayeeAmount
            self.cursivePayerAmount = cursivePayerAmount
            self.dateForDetail = dateForDetail
            self.dateN = dateN
            self.depositDateOpen = depositDateOpen
            self.depositNumber = depositNumber
            self.discount = discount
            self.discountExpiry = discountExpiry
            self.division = division
            self.documentNumber = documentNumber
            self.driverLicense = driverLicense
            self.externalTransferType = externalTransferType
            self.formattedAmount = formattedAmount
            self.isForaBank = isForaBank
            self.isTrafficPoliceService = isTrafficPoliceService
            self.legalAct = legalAct
            self.mcc = mcc
            self.memberID = memberID
            self.merchantIcon = merchantIcon
            self.merchantSubName = merchantSubName
            self.oktmo = oktmo
            self.operation = operation
            self.operationCategory = operationCategory
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
            self.paymentFlow = paymentFlow
            self.paymentMethod = paymentMethod
            self.paymentOperationDetailID = paymentOperationDetailID
            self.paymentTemplateID = paymentTemplateID
            self.paymentTerm = paymentTerm
            self.period = period
            self.printFormType = printFormType
            self.provider = provider
            self.puref = puref
            self.realPayerFIO = realPayerFIO
            self.realPayerINN = realPayerINN
            self.realPayerKPP = realPayerKPP
            self.regCert = regCert
            self.requestDate = requestDate
            self.responseDate = responseDate
            self.returned = returned
            self.serviceName = serviceName
            self.serviceSelect = serviceSelect
            self.shopLink = shopLink
            self.supplierBillID = supplierBillID
            self.transAmm = transAmm
            self.transfer = transfer
            self.transferDate = transferDate
            self.transferNumber = transferNumber
            self.transferReference = transferReference
            self.trnPickupPointName = trnPickupPointName
            self.upno = upno
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
    
    typealias PrintFormType = String
        
    enum PaymentMethod: Equatable {
        
        case cash, cashless
    }
    
    enum Transfer: Equatable {
        
        case accountAdressing
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
        case charityService
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
        case digitalWalletsService
        case direct
        case educationService
        case elecsnet
        case external
        case foreignCard
        case goldenPayment
        case housingAndCommunalService
        case interestDeposit
        case internet
        case `internal`
        case meToMeCredit
        case meToMeDebit
        case mobile
        case networkMarketingService
        case newDirect
        case newDirectAccount
        case newDirectCard
        case other
        case productPaymentCourier
        case productPaymentOffice
        case repaymentLoansAndAccountsService
        case returnOutgoing
        case sberQRPayment
        case securityService
        case sfp
        case socialAndGamesService
        case taxAndStateService
        case transport
        case insuranceService
        case journeyServices
        case unknown(String)
    }
}
