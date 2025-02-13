//
//  ResponseMapper+mapGetOperationDetailByPaymentIDResponse.swift
//
//
//  Created by Igor Malyarov on 26.03.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetOperationDetailByPaymentIDResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetOperationDetailByPaymentIDResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetOperationDetailByPaymentIDResponse.init)
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            account: data.account,
            accountTitle: data.accountTitle,
            amount: data.amount,
            billDate: data.billDate,
            billNumber: data.billNumber,
            cityName: data.cityName,
            claimID: data.claimId,
            comment: data.comment,
            countryName: data.countryName,
            currencyAmount: data.currencyAmount,
            currencyRate: data.currencyRate,
            cursiveAmount: data.cursiveAmount,
            cursivePayerAmount: data.cursivePayerAmount,
            cursivePayeeAmount: data.cursivePayeeAmount,
            dateForDetail: data.dateForDetail,
            depositDateOpen: data.depositDateOpen,
            depositNumber: data.depositNumber,
            division: data.division,
            documentNumber: data.docNumber,
            driverLicense: data.driverLicense,
            externalTransferType: .init(data.externalTransferType),
            isForaBank: data.isForaBank,
            isTrafficPoliceService: data.isTrafficPoliceService,
            mcc: data.MCC,
            memberID: data.memberId,
            merchantIcon: data.merchantIcon,
            merchantSubName: data.merchantSubName,
            operation: data.operation,
            operationCategory: data.operationCategory,
            operationStatus: .init(data.operationStatus),
            oktmo: data.OKTMO,
            payeeAccountID: data.payeeAccountId,
            payeeAccountNumber: data.payeeAccountNumber,
            payeeAmount: data.payeeAmount,
            payeeBankBIC: data.payeeBankBIC,
            payeeBankCorrAccount: data.payeeBankCorrAccount,
            payeeBankName: data.payeeBankName,
            payeeCardID: data.payeeCardId,
            payeeCardNumber: data.payeeCardNumber,
            payeeCheckAccount: data.payeeCheckAccount,
            payeeCurrency: data.payeeCurrency,
            payeeFirstName: data.payeeFirstName,
            payeeFullName: data.payeeFullName,
            payeeINN: data.payeeINN,
            payeeKPP: data.payeeKPP,
            payeeMiddleName: data.payeeMiddleName,
            payeePhone: data.payeePhone,
            payeeSurName: data.payeeSurName,
            payerAccountID: data.payerAccountId,
            payerAccountNumber: data.payerAccountNumber,
            payerAddress: data.payerAddress,
            payerAmount: data.payerAmount,
            payerCardID: data.payerCardId,
            payerCardNumber: data.payerCardNumber,
            payerCurrency: data.payerCurrency,
            payerDocument: data.payerDocument,
            payerFee: data.payerFee,
            payerFirstName: data.payerFirstName,
            payerFullName: data.payerFullName,
            payerINN: data.payerINN,
            payerMiddleName: data.payerMiddleName,
            payerPhone: data.payerPhone,
            payerSurName: data.payerSurName,
            paymentFlow: data.paymentFlow,
            paymentMethod: .init(data.paymentMethod),
            paymentOperationDetailID: data.paymentOperationDetailId,
            paymentTemplateID: data.paymentTemplateId,
            period: data.period,
            printFormType: data.printFormType,
            provider: data.provider,
            puref: data.puref,
            regCert: data.regCert,
            requestDate: data.requestDate,
            responseDate: data.responseDate,
            returned: data.returned,
            serviceSelect: data.serviceSelect,
            serviceName: data.serviceName,
            shopLink: data.shopLink,
            transfer: .init(data.transferEnum),
            transferDate: data.transferDate,
            transferNumber: data.transferNumber,
            transferReference: data.transferReference,
            trnPickupPointName: data.trnPickupPointName
        )
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse.ExternalTransferType {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "ENTITY":     self = .entity
        case "INDIVIDUAL": self = .individual
        default:           return nil
        }
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse.OperationStatus {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "COMPLETE":    self = .complete
        case "IN_PROGRESS": self = .inProgress
        case "REJECTED":    self = .rejected
        default:            return nil
        }
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse.PaymentMethod {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "Наличные":    self = .cash
        case "Безналичный": self = .cashless
        default:            return nil
        }
    }
}
private extension ResponseMapper.GetOperationDetailByPaymentIDResponse.Transfer {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "ACCOUNT_2_ACCOUNT":             self = .accountToAccount
        case "ACCOUNT_2_CARD":                self = .accountToCard
        case "ACCOUNT_2_PHONE":               self = .accountToPhone
        case "ACCOUNT_CLOSE":                 self = .accountClose
        case "ADDRESSING_ACCOUNT":            self = .accountAdressing
        case "ADDRESSING_CASH":               self = .contactAddressingCash
        case "ADDRESSLESS":                   self = .contactAddressless
        case "BANK_DEF":                      self = .bankDef
        case "BEST2PAY":                      self = .bestToPay
        case "C2B_PAYMENT":                   self = .c2bPayment
        case "C2B_QR_DATA":                   self = .c2bQrData
        case "CARD_2_ACCOUNT":                self = .cardToAccount
        case "CARD_2_CARD":                   self = .cardToCard
        case "CARD_2_PHONE":                  self = .cardToPhone
        case "CHANGE_OUTGOING":               self = .changeOutgoing
        case "CHARITY_SERVICE":               self = .charityService
        case "CONTACT_ADDRESSING":            self = .contactAddressing
        case "CONTACT_ADDRESSLESS":           self = .contactAddressless
        case "CONVERSION_ACCOUNT_2_ACCOUNT":  self = .conversionAccountToAccount
        case "CONVERSION_ACCOUNT_2_CARD":     self = .conversionAccountToCard
        case "CONVERSION_ACCOUNT_2_PHONE":    self = .conversionAccountToPhone
        case "CONVERSION_CARD_2_ACCOUNT":     self = .conversionCardToAccount
        case "CONVERSION_CARD_2_CARD":        self = .conversionCardToCard
        case "CONVERSION_CARD_2_PHONE":       self = .conversionCardToPhone
        case "DEPOSIT_CLOSE":                 self = .depositClose
        case "DEPOSIT_OPEN":                  self = .depositOpen
        case "DIGITAL_WALLETS_SERVICE":      self = .digitalWalletsService
        case "DIRECT":                        self = .direct
        case "EDUCATION_SERVICE":            self = .educationService
        case "ELECSNET":                      self = .elecsnet
        case "EXTERNAL":                      self = .external
        case "FOREIGN_CARD":                  self = .foreignCard
        case "GOLDEN_PAYMENT":                self = .goldenPayment
        case "HOUSING_AND_COMMUNAL_SERVICE": self = .housingAndCommunalService
        case "INTEREST_DEPOSIT":              self = .interestDeposit
        case "INTERNAL":                      self = .internal
        case "INTERNET":                      self = .internet
        case "ME2ME_CREDIT":                  self = .meToMeCredit
        case "ME2ME_DEBIT":                   self = .meToMeDebit
        case "MOBILE":                        self = .mobile
        case "NETWORK_MARKETING_SERVICE":    self = .networkMarketingService
        case "NEW_DIRECT":                    self = .newDirect
        case "NEW_DIRECT_ACCOUNT":            self = .newDirectAccount
        case "NEW_DIRECT_CARD":               self = .newDirectCard
        case "OTH":                           self = .other
        case "PRODUCT_PAYMENT_COURIER":       self = .productPaymentCourier
        case "PRODUCT_PAYMENT_OFFICE":        self = .productPaymentOffice
        case "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE": self = .repaymentLoansAndAccountsService
        case "RETURN_OUTGOING":                       self = .returnOutgoing
        case "SBER_QR_PAYMENT":                       self = .sberQRPayment
        case "SECURITY_SERVICE":                      self = .securityService
        case "SFP":                                    self = .sfp
        case "SOCIAL_AND_GAMES_SERVICE":              self = .socialAndGamesService
        case "TAX_AND_STATE_SERVICE":                 self = .taxAndStateService
        case "TRANSPORT":                              self = .transport
        case "INSURANCE_SERVICE":                      self = .insuranceService
        case "JOURNEY_SERVICE":                        self = .journeyServices
        default:
            guard let rawValue else { return nil }
            self = .unknown(rawValue)
        }
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let account: String?
        let accountTitle: String?
        let amount: Decimal
        let billDate: String?
        let billNumber: String?
        let cityName: String?
        let claimId: String
        let comment: String?
        let countryName: String?
        let currencyAmount: String?
        let currencyRate: Decimal?
        let cursiveAmount: String?
        let cursivePayerAmount: String?
        let cursivePayeeAmount: String?
        let dateForDetail: String
        let depositDateOpen: String?
        let depositNumber: String?
        let division: String?
        let docNumber: String?
        let driverLicense: String?
        let externalTransferType: String?
        let isForaBank: Bool?
        let isTrafficPoliceService: Bool
        let MCC: String?
        let memberId: String?
        let merchantIcon: String?
        let merchantSubName: String?
        let operation: String?
        let operationCategory: String?
        let operationStatus: String?
        let OKTMO: String?
        let payeeAccountId: Int?
        let payeeAccountNumber: String?
        let payeeAmount: Decimal?
        let payeeBankBIC: String?
        let payeeBankCorrAccount: String?
        let payeeBankName: String?
        let payeeCardId: Int?
        let payeeCardNumber: String?
        let payeeCheckAccount: String?
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
        let payerAmount: Decimal
        let payerCardId: Int?
        let payerCardNumber: String?
        let payerCurrency: String
        let payerDocument: String?
        let payerFee: Decimal
        let payerFirstName: String
        let payerFullName: String
        let payerINN: String?
        let payerMiddleName: String?
        let payerPhone: String?
        let payerSurName: String?
        let paymentFlow: String?
        let paymentMethod: String?
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
        let serviceSelect: String?
        let serviceName: String?
        let shopLink: String?
        let transferDate: String
        let transferEnum: String?
        let transferNumber: String?
        let transferReference: String?
        let trnPickupPointName: String?
    }
}

private extension ResponseMapper._Data {
    
    typealias PrintFormType = String
}

