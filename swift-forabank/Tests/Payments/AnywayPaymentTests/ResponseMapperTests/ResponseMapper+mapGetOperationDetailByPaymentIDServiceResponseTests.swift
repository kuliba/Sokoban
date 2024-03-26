//
//  ResponseMapper+mapGetOperationDetailByPaymentIDResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    static func mapGetOperationDetailByPaymentIDResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetOperationDetailByPaymentIDResponse? {
        
        let result = map(data, httpURLResponse, mapOrThrow: GetOperationDetailByPaymentIDResponse.init)
        
        return try? result.get()
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
            driverLicense: data.driverLicense,
            externalTransferType: .init(data.externalTransferType),
            isForaBank: data.isForaBank,
            isTrafficPoliceService: data.isTrafficPoliceService,
            mcc: data.MCC,
            memberID: data.memberId,
            merchantIcon: data.merchantIcon,
            merchantSubName: data.merchantSubName,
            operation: data.operation,
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
            paymentMethod: .init(data.paymentMethod),
            paymentOperationDetailID: data.paymentOperationDetailId,
            paymentTemplateID: data.paymentTemplateId,
            period: data.period,
            printFormType: .init(data.printFormType),
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

extension ResponseMapper {
    
    struct GetOperationDetailByPaymentIDResponse: Equatable {
        
        let account: String?
        let accountTitle: String?
        let amount: Decimal
        let billDate: String?
        let billNumber: String?
        let cityName: String?
        let claimID: String
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
        let driverLicense: String?
        let externalTransferType: ExternalTransferType?
        let isForaBank: Bool?
        let isTrafficPoliceService: Bool
        let mcc: String?
        let memberID: String?
        let merchantIcon: String?
        let merchantSubName: String?
        let operation: String?
        let operationStatus: OperationStatus?
        let oktmo: String?
        let payeeAccountID: Int?
        let payeeAccountNumber: String?
        let payeeAmount: Decimal?
        let payeeBankBIC: String?
        let payeeBankCorrAccount: String?
        let payeeBankName: String?
        let payeeCardID: Int?
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
        let payerAccountID: Int
        let payerAccountNumber: String
        let payerAddress: String
        let payerAmount: Decimal
        let payerCardID: Int?
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
        let paymentMethod: PaymentMethod?
        let paymentOperationDetailID: Int
        let paymentTemplateID: Int?
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
        let transfer: Transfer?
        let transferDate: String
        let transferNumber: String?
        let transferReference: String?
        let trnPickupPointName: String?
        
        init(account: String? = nil, accountTitle: String? = nil, amount: Decimal, billDate: String? = nil, billNumber: String? = nil, cityName: String? = nil, claimID: String, comment: String? = nil, countryName: String? = nil, currencyAmount: String? = nil, currencyRate: Decimal? = nil, cursiveAmount: String? = nil, cursivePayerAmount: String? = nil, cursivePayeeAmount: String? = nil, dateForDetail: String, depositDateOpen: String? = nil, depositNumber: String? = nil, division: String? = nil, driverLicense: String? = nil, externalTransferType: ExternalTransferType? = nil, isForaBank: Bool? = nil, isTrafficPoliceService: Bool, mcc: String? = nil, memberID: String? = nil, merchantIcon: String? = nil, merchantSubName: String? = nil, operation: String? = nil, operationStatus: OperationStatus? = nil, oktmo: String? = nil, payeeAccountID: Int? = nil, payeeAccountNumber: String? = nil, payeeAmount: Decimal? = nil, payeeBankBIC: String? = nil, payeeBankCorrAccount: String? = nil, payeeBankName: String? = nil, payeeCardID: Int? = nil, payeeCardNumber: String? = nil, payeeCheckAccount: String? = nil, payeeCurrency: String? = nil, payeeFirstName: String? = nil, payeeFullName: String? = nil, payeeINN: String? = nil, payeeKPP: String? = nil, payeeMiddleName: String? = nil, payeePhone: String? = nil, payeeSurName: String? = nil, payerAccountID: Int, payerAccountNumber: String, payerAddress: String, payerAmount: Decimal, payerCardID: Int? = nil, payerCardNumber: String? = nil, payerCurrency: String, payerDocument: String? = nil, payerFee: Decimal, payerFirstName: String, payerFullName: String, payerINN: String? = nil, payerMiddleName: String? = nil, payerPhone: String? = nil, payerSurName: String? = nil, paymentMethod: PaymentMethod? = nil, paymentOperationDetailID: Int, paymentTemplateID: Int? = nil, period: String? = nil, printFormType: PrintFormType, provider: String? = nil, puref: String? = nil, regCert: String? = nil, requestDate: String, responseDate: String, returned: Bool? = nil, serviceSelect: String? = nil, serviceName: String? = nil, shopLink: String? = nil, transfer: Transfer? = nil, transferDate: String, transferNumber: String? = nil, transferReference: String? = nil, trnPickupPointName: String? = nil
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

extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
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

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse.PrintFormType {
    
    init(_ printFormType: ResponseMapper._Data.PrintFormType) {
        
        switch printFormType {
        case .addressing_cash:           self = .addressing_cash
        case .addressless:               self = .addressless
        case .c2b:                       self = .c2b
        case .changeOutgoing:            self = .changeOutgoing
        case .closeAccount:              self = .closeAccount
        case .closeDeposit:              self = .closeDeposit
        case .contactAddressless:        self = .contactAddressless
        case .direct:                    self = .direct
        case .external:                  self = .external
        case .housingAndCommunalService: self = .housingAndCommunalService
        case .internal:                  self = .internal
        case .internet:                  self = .internet
        case .mobile:                    self = .mobile
        case .newDirect:                 self = .newDirect
        case .returnOutgoing:            self = .returnOutgoing
        case .sberQR:                    self = .sberQR
        case .sbp:                       self = .sbp
        case .sticker:                   self = .sticker
        case .taxAndStateService:        self = .taxAndStateService
        case .transport:                 self = .transport
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
        case "ADDRESSLESS":                   self = .contactAddressless
        case "ADDRESSING_CASH":               self = .contactAddressingCash
        case "BANK_DEF":                      self = .bankDef
        case "BEST2PAY":                      self = .bestToPay
        case "C2B_PAYMENT":                   self = .c2bPayment
        case "C2B_QR_DATA":                   self = .c2bQrData
        case "CARD_2_ACCOUNT":                self = .cardToAccount
        case "CARD_2_CARD":                   self = .cardToCard
        case "CARD_2_PHONE":                  self = .cardToPhone
        case "CHANGE_OUTGOING":               self = .changeOutgoing
        case "CONVERSION_ACCOUNT_2_ACCOUNT":  self = .conversionAccountToAccount
        case "CONVERSION_ACCOUNT_2_CARD":     self = .conversionAccountToCard
        case "CONVERSION_ACCOUNT_2_PHONE":    self = .conversionAccountToPhone
        case "CONVERSION_CARD_2_ACCOUNT":     self = .conversionCardToAccount
        case "CONVERSION_CARD_2_CARD":        self = .conversionCardToCard
        case "CONVERSION_CARD_2_PHONE":       self = .conversionCardToPhone
        case "CONTACT_ADDRESSING":            self = .contactAddressing
        case "DEPOSIT_CLOSE":                 self = .depositClose
        case "DEPOSIT_OPEN":                  self = .depositOpen
        case "ELECSNET":                      self = .elecsnet
        case "EXTERNAL":                      self = .external
        case "HOUSING_AND_COMMUNAL_SERVICE":  self = .housingAndCommunalService
        case "INTERNAL":                      self = .internal
        case "INTERNET":                      self = .internet
        case "INTEREST_DEPOSIT":              self = .interestDeposit
        case "ME2ME_CREDIT":                  self = .meToMeCredit
        case "ME2ME_DEBIT":                   self = .meToMeDebit
        case "MOBILE":                        self = .mobile
        case "NEW_DIRECT":                    self = .direct
        case "OTH":                           self = .other
        case "PRODUCT_PAYMENT_COURIER":       self = .productPaymentCourier
        case "PRODUCT_PAYMENT_OFFICE":        self = .productPaymentOffice
        case "RETURN_OUTGOING":               self = .returnOutgoing
        case "SBER_QR_PAYMENT":               self = .sberQRPayment
        case "SFP":                           self = .sfp
        case "TAX_AND_STATE_SERVICE":         self = .taxAndStateService
        case "TRANSPORT":                     self = .transport
        default:                              return nil
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
        let driverLicense: String?
        let externalTransferType: String?
        let isForaBank: Bool?
        let isTrafficPoliceService: Bool
        let MCC: String?
        let memberId: String?
        let merchantIcon: String?
        let merchantSubName: String?
        let operation: String?
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
    
    enum PrintFormType: String, Codable {
        
        case addressing_cash
        case addressless
        case c2b
        case changeOutgoing
        case closeDeposit
        case closeAccount
        case contactAddressless
        case direct
        case external
        case housingAndCommunalService
        case internet
        case `internal`
        case mobile
        case newDirect
        case returnOutgoing
        case sberQR
        case sbp
        case sticker
        case taxAndStateService
        case transport
    }
}

import AnywayPayment
import RemoteServices
import XCTest

final class ResponseMapper_mapGetOperationDetailByPaymentIDResponseTests: XCTestCase {
    
    func test_map_shouldDeliverNilOnEmptyData() {
        
        XCTAssertNil(map(.empty))
    }
    
    func test_map_shouldDeliverNilOnInvalidData() {
        
        XCTAssertNil(map(.invalidData))
    }
    
    func test_map_shouldDeliverNilOnEmptyJSON() {
        
        XCTAssertNil(map(.emptyJSON))
    }
    
    func test_map_shouldDeliverNilOnEmptyDataResponse() {
        
        XCTAssertNil(map(.emptyDataResponse))
    }
    
    func test_map_shouldDeliverNilOnNullServerResponse() {
        
        XCTAssertNil(map(.nullServerResponse))
    }
    
    func test_map_shouldDeliverNilOnServerError() {
        
        XCTAssertNil(map(.serverError))
    }
    
    func test_map_shouldDeliverNilOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            XCTAssertNil(map(.validData, nonOkResponse))
        }
    }
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .valid())
    }
    
    func test_map_shouldDeliverResponseRich() throws {
        
        try assert(.validDataRich, .valid(
            externalTransferType: .entity,
            operationStatus: .inProgress,
            paymentMethod: .cashless
        ))
    }
    
    // MARK: - Helpers
    
    typealias MappingResult = ResponseMapper.MappingResult<ResponseMapper.GetOperationDetailByPaymentIDResponse>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.GetOperationDetailByPaymentIDResponse? {
        
        ResponseMapper.mapGetOperationDetailByPaymentIDResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: ResponseMapper.GetOperationDetailByPaymentIDResponse,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        XCTAssertNoDiff(map(data), response, file: file, line: line)
    }
}

private extension ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    static func valid(
        account: String = "766440148001",
        accountTitle: String = "Лицевой счет",
        currencyAmount: String = "RUB",
        externalTransferType: ExternalTransferType? = nil,
        operationStatus: OperationStatus? = nil,
        payeeFullName: String = "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        payeeINN: String = "7606052264",
        payeeKPP: String = "760601001",
        payerCardID: Int = 10000204785,
        payerCardNumber: String = "**** **** **92 6035",
        payerINN: String = "692502219386",
        payerMiddleName: String = "Сергеевич",
        paymentMethod: PaymentMethod? = nil,
        paymentTemplateID: Int = 2773,
        puref: String = "iFora||TNS",
        returned: Bool = false,
        transfer: Transfer = .housingAndCommunalService
    ) -> Self {
        
        .init(
            account: account,
            accountTitle: accountTitle,
            amount: 1_000,
            claimID: "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
            currencyAmount: currencyAmount,
            dateForDetail: "17 апреля 2023, 17:13",
            externalTransferType: externalTransferType,
            isTrafficPoliceService: false,
            operationStatus: operationStatus,
            payeeFullName: payeeFullName,
            payeeINN: payeeINN,
            payeeKPP: payeeKPP, 
            payerAccountID: 10004333104,
            payerAccountNumber: "40817810543005000761",
            payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
            payerAmount: 1_000,
            payerCardID: payerCardID,
            payerCardNumber: payerCardNumber,
            payerCurrency: "RUB",
            payerFee: 0,
            payerFirstName: "Кирилл",
            payerFullName: "Большаков Кирилл Сергеевич",
            payerINN: payerINN,
            payerMiddleName: payerMiddleName,
            paymentMethod: paymentMethod, 
            paymentOperationDetailID: 57723,
            paymentTemplateID: paymentTemplateID,
            printFormType: .housingAndCommunalService,
            puref: puref,
            requestDate: "17.04.2023 17:13:36",
            responseDate: "17.04.2023 17:13:38",
            returned: returned,
            transfer: transfer,
            transferDate: "17.04.2023"
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
    static let validDataRich: Data = String.validDataRich.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let validData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "account": "766440148001",
        "accountTitle": "Лицевой счет",
        "amount": 1000,
        "cityName": null,
        "claimId": "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        "comment": null,
        "countryName": null,
        "currencyAmount": "RUB",
        "cursiveAmount": null,
        "cursivePayeeAmount": null,
        "cursivePayerAmount": null,
        "dateForDetail": "17 апреля 2023, 17:13",
        "externalTransferType": null,
        "isForaBank": null,
        "isTrafficPoliceService": false,
        "MCC": null,
        "OKTMO": null,
        "operation": null,
        "payerAccountId": 10004333104,
        "payerAccountNumber": "40817810543005000761",
        "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        "payerAmount": 1000,
        "payerCardId": 10000204785,
        "payerCardNumber": "**** **** **92 6035",
        "payerCurrency": "RUB",
        "payerDocument": null,
        "payerFee": 0,
        "payerFirstName": "Кирилл",
        "payerFullName": "Большаков Кирилл Сергеевич",
        "payerINN": "692502219386",
        "payerMiddleName": "Сергеевич",
        "payerPhone": null,
        "payerSurName": null,
        "payeeAccountId": null,
        "payeeAccountNumber": null,
        "payeeAmount": null,
        "payeeBankBIC": null,
        "payeeBankCorrAccount": null,
        "payeeBankName": null,
        "payeeCardId": null,
        "payeeCardNumber": null,
        "payeeCurrency": null,
        "payeeFirstName": null,
        "payeeFullName": "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        "payeeINN": "7606052264",
        "payeeKPP": "760601001",
        "payeeMiddleName": null,
        "payeePhone": null,
        "payeeSurName": null,
        "paymentMethod": null,
        "paymentOperationDetailId": 57723,
        "paymentTemplateId": 2773,
        "period": null,
        "printFormType": "housingAndCommunalService",
        "provider": null,
        "puref": "iFora||TNS",
        "requestDate": "17.04.2023 17:13:36",
        "responseDate": "17.04.2023 17:13:38",
        "returned": false,
        "transferDate": "17.04.2023",
        "transferEnum": "HOUSING_AND_COMMUNAL_SERVICE",
        "transferNumber": null,
        "transferReference": null,
        "trnPickupPointName": null
    }
}
"""
    
    static let validDataRich = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "account": "766440148001",
        "accountTitle": "Лицевой счет",
        "amount": 1000,
        "cityName": null,
        "claimId": "7877f00d-0f37-46f7-a9d5-4eaf1ac84e32",
        "comment": null,
        "countryName": null,
        "currencyAmount": "RUB",
        "cursiveAmount": null,
        "cursivePayeeAmount": null,
        "cursivePayerAmount": null,
        "dateForDetail": "17 апреля 2023, 17:13",
        "externalTransferType": "ENTITY",
        "isForaBank": null,
        "isTrafficPoliceService": false,
        "MCC": null,
        "OKTMO": null,
        "operation": null,
        "operationStatus": "IN_PROGRESS",
        "payerAccountId": 10004333104,
        "payerAccountNumber": "40817810543005000761",
        "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ",
        "payerAmount": 1000,
        "payerCardId": 10000204785,
        "payerCardNumber": "**** **** **92 6035",
        "payerCurrency": "RUB",
        "payerDocument": null,
        "payerFee": 0,
        "payerFirstName": "Кирилл",
        "payerFullName": "Большаков Кирилл Сергеевич",
        "payerINN": "692502219386",
        "payerMiddleName": "Сергеевич",
        "payerPhone": null,
        "payerSurName": null,
        "payeeAccountId": null,
        "payeeAccountNumber": null,
        "payeeAmount": null,
        "payeeBankBIC": null,
        "payeeBankCorrAccount": null,
        "payeeBankName": null,
        "payeeCardId": null,
        "payeeCardNumber": null,
        "payeeCurrency": null,
        "payeeFirstName": null,
        "payeeFullName": "ПАО ТНС ЭНЕРГО ЯРОСЛАВЛЬ",
        "payeeINN": "7606052264",
        "payeeKPP": "760601001",
        "payeeMiddleName": null,
        "payeePhone": null,
        "payeeSurName": null,
        "paymentMethod": "Безналичный",
        "paymentOperationDetailId": 57723,
        "paymentTemplateId": 2773,
        "period": null,
        "printFormType": "housingAndCommunalService",
        "provider": null,
        "puref": "iFora||TNS",
        "requestDate": "17.04.2023 17:13:36",
        "responseDate": "17.04.2023 17:13:38",
        "returned": false,
        "transferDate": "17.04.2023",
        "transferEnum": "HOUSING_AND_COMMUNAL_SERVICE",
        "transferNumber": null,
        "transferReference": null,
        "trnPickupPointName": null
    }
}
"""
}
