//
//  ServerCommandsPaymentOperationDetailTests.swift
//  ForaBankTests
//
//  Created by Андрей Лятовец on 1/24/22.
//

import XCTest
@testable import ForaBank

class ServerCommandsPaymentOperationDetailTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsPaymentOperationDetailTests.self)
    
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.iso8601
    
    //MARK: - GetAllLatestPayments
    
    func testGetAllLatestPayments_Response_Encoding() throws {
        // given
        
        let command = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetAllLatestPayments(token: "",
                                              isPhonePayments: false,
                                              isServicePayments: true,
                                              isMobilePayments: true,
                                              isInternetPayments: false,
                                              isTransportPayments: true,
                                              isTaxAndStateServicePayments: false,
                                              isOutsidePayments: true)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 7)
        
        XCTAssertEqual(command.parameters?[0].name, "isPhonePayments")
        XCTAssertEqual(command.parameters?[1].name, "isServicePayments")
        XCTAssertEqual(command.parameters?[2].name, "isMobilePayments")
        XCTAssertEqual(command.parameters?[3].name, "isInternetPayments")
        XCTAssertEqual(command.parameters?[4].name, "isTransportPayments")
        XCTAssertEqual(command.parameters?[5].name, "isTaxAndStateServicePayments")
        XCTAssertEqual(command.parameters?[6].name, "isOutsidePayments")
        
        XCTAssertEqual(command.parameters?[0].value, "false")
        XCTAssertEqual(command.parameters?[1].value, "true")
        XCTAssertEqual(command.parameters?[2].value, "true")
        XCTAssertEqual(command.parameters?[3].value, "false")
        XCTAssertEqual(command.parameters?[4].value, "true")
        XCTAssertEqual(command.parameters?[5].value, "false")
        XCTAssertEqual(command.parameters?[6].value, "true")
    }
    
    func testGetAllLatestPayments_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetAllLatestPayments", withExtension: "json")!
        let json = try Data(contentsOf: url)

        let date = Date.dateUTC(with: 1653570551608)

        let data = PaymentGeneralData(amount: "10000.00",
                                      bankId: BankID.foraBankID.rawValue,
                                      bankName: "ФОРА-БАНК",
                                      date: date,
                                      paymentDate: "26.05.2022 16:09:11",
                                      phoneNumber: "9636124249",
                                      type: .phone)

        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetAllLatestPayments.Response(statusCode: .ok,
                                                       errorMessage: "string",
                                                       data: [data])

        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetAllLatestPayments.Response.self, from: json)

        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestInternetPayments
    
    func testGetLatestInternetPayments_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetLatestInternetPayments", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentServiceData(additionalList: [.init(fieldTitle: "Лицевой счет у Получателя",
                                                             fieldName: "a3_PERSONAL_ACCOUNT_5_5",
                                                             fieldValue: "1234567890",
                                                             svgImage: "string")],
                                      amount: 100,
                                      date: date,
                                      paymentDate: "21.12.2021 11:04:26",
                                      puref: "iFora||4285",
                                      type: .internet,
                                      lastPaymentName: nil)
        
        let expected = ServerCommands.PaymentOperationDetailContoller
                        .GetLatestInternetPayments.Response(statusCode: .ok,
                                                            errorMessage: "string",
                                                            data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestInternetPayments.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestMobilePayments
    
    func testGetLatestMobilePayments_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetLatestMobilePayments", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentServiceData(additionalList: [.init(fieldTitle: "Лицевой счет у Получателя",
                                                             fieldName: "a3_PERSONAL_ACCOUNT_5_5",
                                                             fieldValue: "1234567890",
                                                             svgImage: "string")],
                                      amount: 100,
                                      date: date,
                                      paymentDate: "21.12.2021 11:04:26",
                                      puref: "iFora||4285",
                                      type: .mobile,
                                      lastPaymentName: nil)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestMobilePayments.Response(statusCode: .ok,
                                                          errorMessage: "string",
                                                          data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestMobilePayments.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestPayments
    
    func testGetLatestPayments_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetLatestPayments", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentGeneralData(amount: "100",
                                      bankId: "100000000004",
                                      bankName: "Тинькофф Банк",
                                      date: date,
                                      paymentDate: "21.12.2021 11:04:26",
                                      phoneNumber: "9998887766",
                                      type: .phone)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestPayments.Response(statusCode: .ok,
                                                    errorMessage: "string",
                                                    data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestPayments.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestPhonePayments
    
    func testGetLatestPhonePayments_Response_Encoding() throws {
        // given
        let command = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestPhonePayments(token: "",
                                                payload: .init(phoneNumber: "9998887766"))
        
        let expected = "{\"phoneNumber\":\"9998887766\"}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testGetLatestPhonePayments_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetLatestPhonePayments", withExtension: "json")!
        let json = try Data(contentsOf: url)

        let data = PaymentPhoneData(bankId: "string",
                                    bankName: "string",
                                    payment: true,
                                    defaultBank: false)

        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestPhonePayments.Response(statusCode: .ok,
                                                        errorMessage: "string",
                                                        data: [data])

        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestPhonePayments.Response.self, from: json)

        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestServicePayments
    
    func testGetLatestServicePayments_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetLatestServicePayments", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentServiceData(additionalList: [.init(fieldTitle: "Лицевой счет у Получателя",
                                                             fieldName: "a3_PERSONAL_ACCOUNT_5_5",
                                                             fieldValue: "1234567890",
                                                             svgImage: "string")],
                                      amount: 100,
                                      date: date,
                                      paymentDate: "21.12.2021 11:04:26",
                                      puref: "iFora||4285",
                                      type: .service,
                                      lastPaymentName: nil)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestServicePayments.Response(statusCode: .ok,
                                                           errorMessage: "string",
                                                           data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestServicePayments.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetLatestTransportPayments
    
    func testGetLatestTransportPayments_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetLatestTransportPayments", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentServiceData(additionalList: [.init(fieldTitle: "Лицевой счет у Получателя",
                                                             fieldName: "a3_PERSONAL_ACCOUNT_5_5",
                                                             fieldValue: "1234567890",
                                                             svgImage: "string")],
                                      amount: 100,
                                      date: date,
                                      paymentDate: "21.12.2021 11:04:26",
                                      puref: "iFora||4285",
                                      type: .transport,
                                      lastPaymentName: nil)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetLatestTransportPayments.Response(statusCode: .ok,
                                                            errorMessage: "string",
                                                            data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetLatestTransportPayments.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetOperationDetail
    
    func testGetOperationDetail_Response_Encoding() throws {
        // given
        let command = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetOperationDetail(token: "",
                                            payload: .init(documentId: "string"))
        
        let expected = "{\"documentId\":\"string\"}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testGetOperationDetail_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetOperationDetail", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let data = OperationDetailData(oktmo: "36634436",
                                       account: "1001200158",
                                       accountTitle: "1001200158",
                                       amount: 250.5,
                                       billDate: "2019-07-19",
                                       billNumber: "2213616660",
                                       claimId: "d3388cf0-68dd-437b-84b2-77ee4ae4abbf",
                                       comment: "Перевод за еду",
                                       countryName: "УЗБЕКИСТАН",
                                       currencyAmount: "RUB",
                                       dateForDetail: "21 Декабря 2021, 22:29",
                                       division: "123456",
                                       driverLicense: "2213616660",
                                       externalTransferType: .entity,
                                       isForaBank: true,
                                       isTrafficPoliceService: false,
                                       memberId: "EVOCA",
                                       operation: "Перевод юридическому лицу в сторонний банк",
                                       payeeAccountId: 10004111477,
                                       payeeAccountNumber: "40817810052005000621",
                                       payeeAmount: 1001,
                                       payeeBankBIC: "044525341",
                                       payeeBankCorrAccount: "30101810300000000341",
                                       payeeBankName: "ЭвокаБанк",
                                       payeeCardId: 10004111477,
                                       payeeCardNumber: "**** **** **50 8437",
                                       payeeCurrency: "RUR",
                                       payeeFirstName: "Петр",
                                       payeeFullName: "Петр Петрович П.",
                                       payeeINN: "7736520080",
                                       payeeKPP: "997650001",
                                       payeeMiddleName: "Петрович",
                                       payeePhone: "+9998887766",
                                       payeeSurName: "Петров",
                                       payerAccountId: 10004111477,
                                       payerAccountNumber: "40817810052005000621",
                                       payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 141006, Московская обл, Мытищи г, Олимпийский пр-кт ,  д. 13,  корп. 2,  кв. 9",
                                       payerAmount: 1011.01,
                                       payerCardId: 10004111477,
                                       payerCardNumber: "**** **** **50 8437",
                                       payerCurrency: "RUB",
                                       payerDocument: "Паспорт гражданина РФ 12 34 № 5678901 выдан 01.01.1973 ОТДЕЛОМ УФМС РОССИИ ПО МОСКВОСКОЙ ОБЛАСТИ В ЦЕНТРАЛЬНОМ РАЙОНЕ Г. ХИМКИ",
                                       payerFee: 10.01,
                                       payerFirstName: "Иван",
                                       payerFullName: "Иван Иванович И.",
                                       payerINN: "123456789012",
                                       payerMiddleName: "Иванович",
                                       payerPhone: "9998887766",
                                       payerSurName: "Иванов",
                                       paymentOperationDetailId: 1,
                                       paymentTemplateId: 1,
                                       period: "2021-12-21",
                                       printFormType: .internal,
                                       provider: "ПАО \"Мобильные ТелеСистемы\"",
                                       puref: "iFora||ContactAddressless",
                                       regCert: "2941881861",
                                       requestDate: "20.12.2021 13:06:05",
                                       responseDate: "20.12.2021 13:06:13",
                                       returned: true,
                                       transferDate: "20.12.2021",
                                       transferEnum: .cardToCard,
                                       transferNumber: "A1355080358996010000057CAFC75755",
                                       transferReference: "848197415",
                                       cursivePayerAmount: "Двести пятьдесять рублей 50 копеек",
                                       cursivePayeeAmount: "Одна тысяча один рубль",
                                       cursiveAmount: "Двести пятьдесять рублей 50 копеек",
                                       serviceSelect: nil,
                                       serviceName: nil,
                                       merchantSubName: nil,
                                       merchantIcon: nil,
                                       operationStatus: nil,
                                       shopLink: nil,
                                       payeeCheckAccount: nil,
                                       depositNumber: nil,
                                       depositDateOpen: nil,
                                       currencyRate: 250.5,
                                       mcc: nil,
                                       printData: nil,
                                       paymentMethod: nil)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetOperationDetail.Response(statusCode: .ok,
                                                    errorMessage: "string",
                                                    data: data)
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetOperationDetail.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetOperationDetail_MinResponse_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetOperationDetailMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let data = OperationDetailData(oktmo: nil, account: nil,
                                       accountTitle: nil,
                                       amount: 250.5,
                                       billDate: nil,
                                       billNumber: nil,
                                       claimId: "d3388cf0-68dd-437b-84b2-77ee4ae4abbf",
                                       comment: nil,
                                       countryName: nil,
                                       currencyAmount: "RUB",
                                       dateForDetail: "21 Декабря 2021, 22:29",
                                       division: nil,
                                       driverLicense: nil,
                                       externalTransferType: nil,
                                       isForaBank: nil,
                                       isTrafficPoliceService: false,
                                       memberId: nil,
                                       operation: nil,
                                       payeeAccountId: nil,
                                       payeeAccountNumber: nil,
                                       payeeAmount: nil,
                                       payeeBankBIC: nil,
                                       payeeBankCorrAccount: nil,
                                       payeeBankName: nil,
                                       payeeCardId: nil,
                                       payeeCardNumber: nil,
                                       payeeCurrency: nil,
                                       payeeFirstName: nil,
                                       payeeFullName: nil,
                                       payeeINN: nil,
                                       payeeKPP: nil,
                                       payeeMiddleName: nil,
                                       payeePhone: nil,
                                       payeeSurName: nil,
                                       payerAccountId: 10004111477,
                                       payerAccountNumber: "40817810052005000621",
                                       payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 141006, Московская обл, Мытищи г, Олимпийский пр-кт ,  д. 13,  корп. 2,  кв. 9",
                                       payerAmount: 1011.01,
                                       payerCardId: nil,
                                       payerCardNumber: nil,
                                       payerCurrency: "RUB",
                                       payerDocument: nil,
                                       payerFee: 10.01,
                                       payerFirstName: "Иван",
                                       payerFullName: "Иван Иванович И.",
                                       payerINN: "123456789012",
                                       payerMiddleName: nil,
                                       payerPhone: nil,
                                       payerSurName: "Иванов",
                                       paymentOperationDetailId: 1,
                                       paymentTemplateId: nil,
                                       period: nil,
                                       printFormType: .internal,
                                       provider: nil,
                                       puref: nil,
                                       regCert: nil,
                                       requestDate: "20.12.2021 13:06:05",
                                       responseDate: "20.12.2021 13:06:13",
                                       returned: nil,
                                       transferDate: "20.12.2021",
                                       transferEnum: nil,
                                       transferNumber: nil,
                                       transferReference: nil,
                                       cursivePayerAmount: "Двести пятьдесять рублей 50 копеек",
                                       cursivePayeeAmount: "Одна тысяча один рубль",
                                       cursiveAmount: "Двести пятьдесять рублей 50 копеек",
                                       serviceSelect: nil,
                                       serviceName: nil,
                                       merchantSubName: nil,
                                       merchantIcon: nil,
                                       operationStatus: nil,
                                       shopLink: nil,
                                       payeeCheckAccount: nil,
                                       depositNumber: nil,
                                       depositDateOpen: nil,
                                       currencyRate: 250.5,
                                       mcc: nil,
                                       printData: nil,
                                       paymentMethod: nil)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetOperationDetail.Response(statusCode: .ok,
                                                    errorMessage: "string",
                                                    data: data)
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetOperationDetail.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetPaymentCountries
    
    func testGetPaymentCountries_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetPaymentCountries", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentCountryData(countryCode: "AM",
                                      countryName: "Армения",
                                      date: date,
                                      firstName: "Иван",
                                      middleName: "Иванович",
                                      paymentDate: "21.12.2021 11:04:26",
                                      phoneNumber: "37491040486",
                                      puref: "iFora||TransferArmBBClientP",
                                      shortName: "Иванов И.",
                                      surName: "Иванов",
                                      type: .outside)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetPaymentCountries.Response(statusCode: .ok,
                                                    errorMessage: "string",
                                                    data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetPaymentCountries.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetPaymentCountries_MinResponse_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetPaymentCountriesMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let date = Date.dateUTC(with: 1653570551608)
        
        let data = PaymentCountryData(countryCode: "AM",
                                      countryName: "Армения",
                                      date: date,
                                      firstName: nil,
                                      middleName: nil,
                                      paymentDate: "21.12.2021 11:04:26",
                                      phoneNumber: nil,
                                      puref: "iFora||TransferArmBBClientP",
                                      shortName: "Иванов И.",
                                      surName: nil,
                                      type: .outside)
        
        let expected = ServerCommands
                        .PaymentOperationDetailContoller
                        .GetPaymentCountries.Response(statusCode: .ok,
                                                    errorMessage: "string",
                                                    data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands
                                        .PaymentOperationDetailContoller
                                        .GetPaymentCountries.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
