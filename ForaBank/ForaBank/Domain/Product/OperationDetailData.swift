//
//  OperationDetailData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

struct OperationDetailData: Codable, Hashable {

    let oktmo: String?
    let account: String?
    let accountTitle: String?
    let amount: Double
    let billDate: String?
    let billNumber: String?
    let claimId: String
    let comment: String?
    let countryName: String?
    let currencyAmount: String?
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
    let paymentMethod: PaymentMethod?
    
    enum PaymentMethod: String, Codable, Hashable, Unknownable {
    
        case cash = "Наличные"
        case cashless = "Безналичный"
        case unknown
    }
    
    enum ExternalTransferType: String, Codable, Hashable, Unknownable {
        
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
    
    enum TransferEnum: String, Codable, Hashable, Unknownable {
        
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
        case contactAddressless = "ADDRESSLESS"
        case contactAddressingCash = "ADDRESSING_CASH"
        case depositOpen = "DEPOSIT_OPEN"
        case direct = "NEW_DIRECT"
        case elecsnet = "ELECSNET"
        case external = "EXTERNAL"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case `internal` = "INTERNAL"
        case internet = "INTERNET"
        case meToMeCredit = "ME2ME_CREDIT"
        case meToMeDebit = "ME2ME_DEBIT"
        case mobile = "MOBILE"
        case other = "OTH"
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
        case c2bQrData = "C2B_QR_DATA"
        case c2bPayment = "C2B_PAYMENT"
        case interestDeposit = "INTEREST_DEPOSIT"
        case sberQRPayment = "SBER_QR_PAYMENT"
        case productPaymentOffice = "PRODUCT_PAYMENT_OFFICE"
        case productPaymentCourier = "PRODUCT_PAYMENT_COURIER"
        case unknown
    }
    
    struct PrintMapData: Codable, Hashable {
        
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
        case paymentMethod
    }
}

extension OperationDetailData {
    
    static func make(amount: Double, productFrom: ProductData, productTo: ProductData, paymentOperationDetailId: Int, transferEnum: OperationDetailData.TransferEnum) -> OperationDetailData {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return .init(oktmo: nil, account: nil, accountTitle: nil, amount: amount, billDate: nil, billNumber: nil, claimId: UUID().uuidString, comment: "Перевод с конверсией денежных средств между счетами Клиента", countryName: nil, currencyAmount: productFrom.currency, dateForDetail: date, division: nil, driverLicense: nil, externalTransferType: nil, isForaBank: nil, isTrafficPoliceService: false, memberId: nil, operation: "Перевод денежных средств между счетами Клиента с конверсией по курсу банка", payeeAccountId: productTo.id, payeeAccountNumber: productTo.accountNumber, payeeAmount: productTo.balanceValue, payeeBankBIC: nil, payeeBankCorrAccount: nil, payeeBankName: productTo.displayName, payeeCardId: nil, payeeCardNumber: productTo.number, payeeCurrency: productTo.currency, payeeFirstName: nil, payeeFullName: productTo.productName, payeeINN: nil, payeeKPP: nil, payeeMiddleName: nil, payeePhone: nil, payeeSurName: nil, payerAccountId: productFrom.id, payerAccountNumber: productFrom.accountNumber ?? "", payerAddress: "", payerAmount: amount, payerCardId: productFrom.id, payerCardNumber: productFrom.number, payerCurrency: productFrom.currency, payerDocument: nil, payerFee: 0, payerFirstName: productFrom.displayName, payerFullName: productFrom.productName, payerINN: nil, payerMiddleName: productFrom.displayName, payerPhone: nil, payerSurName: nil, paymentOperationDetailId: paymentOperationDetailId, paymentTemplateId: nil, period: nil, printFormType: .internal, provider: nil, puref: nil, regCert: nil, requestDate: date, responseDate: date, returned: nil, transferDate: date, transferEnum: transferEnum, transferNumber: nil, transferReference: nil, cursivePayerAmount: nil, cursivePayeeAmount: nil, cursiveAmount: nil, serviceSelect: nil, serviceName: nil, merchantSubName: nil, merchantIcon: nil, operationStatus: nil, shopLink: nil, payeeCheckAccount: nil, depositNumber: nil, depositDateOpen: nil, currencyRate: nil, mcc: nil, printData: nil, paymentMethod: nil)
    }
}

extension OperationDetailData {
    
    var templateName: String {
        
        switch transferEnum {
        case .transport:
            return payeeFullName ?? "Транспорт"
        case .taxAndStateService:
            return payeeFullName ?? "Налоги и госуслуги"
        case .accountToAccount, .cardToAccount, .cardToCard:
            return payeeFullName ?? "Перевод между своими"
        case .accountToCard:
            return payeeFullName ?? "Между своими"
        case .accountToPhone, .cardToPhone:
            return payeeFullName ?? "Перевод внутри банка"
        case .contactAddressingCash, .contactAddressless:
            return payeeFullName ?? "Перевод Contact"
        case .direct:
            return payeeFullName ?? "Перевод МИГ"
        case .elecsnet:
            return "В другой банк"
        case .external:
            return payeeFullName ?? "Перевод по реквизитам"
        case .housingAndCommunalService:
            return payeeFullName ?? "ЖКХ"
        case .internet:
            return payeeFullName ?? "Интернет и ТВ"
        case .mobile:
            return payeeFullName ?? "Мобильная связь"
        case .sfp:
            return payeeFullName ?? payeeBankName ?? "Исходящие СБП"
        case .conversionAccountToAccount:
            return payeeFullName ?? "Перевод между счетами"
        case .conversionAccountToCard:
            return payeeFullName ?? "Перевод со счета на карту"
        case .conversionCardToAccount:
            return payeeFullName ?? "Перевод с карты на счет"
        case .conversionCardToCard:
            return payeeFullName ?? "Перевод с карты на карту"
        case .conversionAccountToPhone, .conversionCardToPhone:
            return payeeFullName ?? payeePhone ?? "Перевод между счетами"
        default:
            return payeeFullName ?? "Шаблон по операции"
        }
    }
}

extension OperationDetailData {
    
    var payerTransferData: TransferData.Payer {
    
        return .init(
            inn: payerINN,
            accountId: payerCardId == nil ? payerAccountId : nil,
            accountNumber: payerAccountNumber,
            cardId: payerCardId,
            cardNumber: payerCardNumber,
            phoneNumber: payerPhone
        )
    }
    
    var payerGeneralTransferData: TransferData.Payer {
    
        return .init(
            inn: nil,
            accountId: payerCardId == nil ? payerAccountId : nil,
            accountNumber: nil,
            cardId: payerCardId,
            cardNumber: nil,
            phoneNumber: nil
        )
    }
    
    var payeeExternal: TransferGeneralData.PayeeExternal? {
        
        guard let payeeAccountNumber,
              let payeeFullName else {
            return nil
        }
        
        return .init(
            inn: payeeINN == "" ? nil : payeeINN,
            kpp: payeeKPP,
            accountId: payeeAccountId,
            accountNumber: payeeAccountNumber,
            bankBIC: payeeBankBIC,
            cardId: payeeCardId,
            cardNumber: payeeCardNumber,
            compilerStatus: nil,
            date: nil,
            name: payeeFullName,
            tax: nil
        )
    }
    
    var payeeInternal: TransferGeneralData.PayeeInternal {
        
        return .init(
            accountId: payeeAccountId,
            accountNumber: payeeAccountNumber,
            cardId: payeeCardId,
            cardNumber: payeeCardNumber,
            phoneNumber: payeePhone,
            productCustomName: nil
        )
    }
    
    var shouldHaveTemplateButton: Bool {
        
        switch self.transferEnum {
        case .interestDeposit,
             .elecsnet,
             .depositOpen,
             .depositClose,
             .accountClose,
             .bestToPay,
             .meToMeCredit,
             .changeOutgoing,
             .returnOutgoing,
             .c2bQrData,
             .c2bPayment,
             .bankDef,
             .sberQRPayment,
             .other:
            return false
        default:
            return true
        }
    }
}

extension OperationDetailData {
    
    var payerProductId: Int? {
        [
            self.payerCardId,
            self.payerAccountId
        ].compactMap { $0 }.first
        
    }
    var payerProductNumber: String? {
        [
            self.payerCardNumber,
            self.payerAccountNumber
        ].compactMap { $0 }.first
    }
    var payeeProductId: Int? {
        [
            self.payeeCardId,
            self.payeeAccountId
        ].compactMap { $0 }.first
    }
    var payeeProductNumber: String? {
        [
            self.payeeCardNumber,
            self.payeeAccountNumber
        ].compactMap { $0 }.first
    }
}

extension OperationDetailData {
    
    static func stub(
        payerCardId: Int? = nil,
        payerAccountId: Int = 10,
        amount: Double = 100,
        paymentTemplateId: Int? = nil,
        transferEnum: OperationDetailData.TransferEnum? = .accountClose,
        payeeFullName: String? = nil,
        payeePhone: String? = nil,
        payeeAccountNumber: String = "payeeAccountNumber",
        operationStatus: OperationStatus = .complete
    ) -> OperationDetailData {
        
        return .init(
            oktmo: nil,
            account: nil,
            accountTitle: nil,
            amount: amount,
            billDate: nil,
            billNumber: nil,
            claimId: "",
            comment: nil,
            countryName: nil,
            currencyAmount: "",
            dateForDetail: "",
            division: nil,
            driverLicense: nil,
            externalTransferType: .individual,
            isForaBank: false,
            isTrafficPoliceService: false,
            memberId: nil,
            operation: nil,
            payeeAccountId: nil,
            payeeAccountNumber: payeeAccountNumber,
            payeeAmount: nil,
            payeeBankBIC: nil,
            payeeBankCorrAccount: nil,
            payeeBankName: nil,
            payeeCardId: nil,
            payeeCardNumber: nil,
            payeeCurrency: nil,
            payeeFirstName: nil,
            payeeFullName: payeeFullName,
            payeeINN: nil,
            payeeKPP: nil,
            payeeMiddleName: nil,
            payeePhone: payeePhone,
            payeeSurName: nil,
            payerAccountId: payerAccountId,
            payerAccountNumber: "payerAccountNumber",
            payerAddress: "",
            payerAmount: 11,
            payerCardId: payerCardId,
            payerCardNumber: "payerCardNumber",
            payerCurrency: "",
            payerDocument: nil,
            payerFee: 10,
            payerFirstName: "",
            payerFullName: "",
            payerINN: nil,
            payerMiddleName: nil,
            payerPhone: nil,
            payerSurName: nil,
            paymentOperationDetailId: 1,
            paymentTemplateId: paymentTemplateId,
            period: nil,
            printFormType: .addressing_cash,
            provider: nil,
            puref: nil,
            regCert: nil,
            requestDate: "",
            responseDate: "",
            returned: nil,
            transferDate: "",
            transferEnum: transferEnum,
            transferNumber: nil,
            transferReference: nil,
            cursivePayerAmount: nil,
            cursivePayeeAmount: nil,
            cursiveAmount: nil,
            serviceSelect: nil,
            serviceName: nil,
            merchantSubName: nil,
            merchantIcon: nil,
            operationStatus: operationStatus,
            shopLink: nil,
            payeeCheckAccount: nil,
            depositNumber: nil,
            depositDateOpen: nil,
            currencyRate: nil,
            mcc: nil,
            printData: nil,
            paymentMethod: nil)
    }
}
