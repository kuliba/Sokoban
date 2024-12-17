//
//  ServerCommandsDepositControllerTests.swift
//  ForaBankTests
//
//  Created by Андрей Лятовец on 1/31/22.
//

import XCTest
@testable import ForaBank

class ServerCommandsDepositControllerTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsDepositControllerTests.self)
    
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let dateFormatter = DateFormatter.iso8601
    
    //MARK: - GetDepositInfo
    
    func testGetDepositInfo_Response_Encoding() throws {
        
        // given
        
        let command = ServerCommands.DepositController.GetDepositInfo(token: "", payload: .init(id: 10000184511))
        
        let expected = "{\"id\":10000184511}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testGetDepositInfo_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetDepositInfo", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let dateEnd = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateNext = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateOpen = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        
        let data = DepositInfoDataItem(id: 10000184511,
                                       initialAmount: 1000,
                                       termDay: "540",
                                       interestRate: 10000184511,
                                       sumPayInt: 1000,
                                       sumCredit: 1000,
                                       sumDebit: 1000,
                                       sumAccInt: 1000,
                                       balance: 1000,
                                       sumPayPrc: 1000,
                                       dateOpen: dateOpen,
                                       dateEnd: dateEnd,
                                       dateNext: dateNext)
        
        
        let expected = ServerCommands.DepositController.GetDepositInfo.Response(statusCode: .ok,
                                                                                errorMessage: "string",
                                                                                data: data)
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetDepositInfo_MinResponse_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetDepositInfoMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let dateEnd = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateNext = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateOpen = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        
        let data = DepositInfoDataItem(id: 10000184511,
                                       initialAmount: 1000,
                                       termDay: "540",
                                       interestRate: 10000184511,
                                       sumPayInt: 1000,
                                       sumCredit: nil,
                                       sumDebit: nil,
                                       sumAccInt: 1000,
                                       balance: 1000,
                                       sumPayPrc: nil,
                                       dateOpen: dateOpen,
                                       dateEnd: dateEnd,
                                       dateNext: dateNext)
        
        let expected = ServerCommands.DepositController.GetDepositInfo.Response(statusCode: .ok,
                                                                                errorMessage: "string",
                                                                                data: data)
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetDepositInfo_ServerResponse_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetDepositInfoServerResponse", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let dateEnd = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateNext = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        let dateOpen = try Date.date(from: "2022-01-20T11:52:41.707Z", formatter: dateFormatter)
        
        let data = DepositInfoDataItem(id: 10001765678,
                                       initialAmount: 100831.02,
                                       termDay: "540",
                                       interestRate: 0.01,
                                       sumPayInt: 856.47,
                                       sumCredit: 0,
                                       sumDebit: 100831.02,
                                       sumAccInt: 0,
                                       balance: 100856.47,
                                       sumPayPrc: 856.47,
                                       dateOpen: dateOpen,
                                       dateEnd: dateEnd,
                                       dateNext: dateNext)
        
        let expected = ServerCommands.DepositController.GetDepositInfo.Response(statusCode: .ok,
                                                                                errorMessage: nil,
                                                                                data: data)
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetDepositStatement
    
    func testGetDepositStatement_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetDepositStatement", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        
        let data = ProductStatementData(mcc: 3245,
                                        accountId: 10004111477,
                                        accountNumber: "70601810711002740401",
                                        amount: 144.21,
                                        cardTranNumber: "4256901080508437",
                                        city: "string",
                                        comment: "Перевод денежных средств. НДС не облагается.",
                                        country: "string",
                                        currencyCodeNumeric: 810,
                                        date: date,
                                        deviceCode: "string",
                                        documentAmount: 144.21,
                                        documentId: 10230444722,
                                        fastPayment: .init(documentComment: "string",
                                                           foreignBankBIC: "044525491",
                                                           foreignBankID: "10000001153",
                                                           foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"",
                                                           foreignName: "Петров Петр Петрович",
                                                           foreignPhoneNumber: "70115110217",
                                                           opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string"),
                                        groupName: "Прочие операции",
                                        isCancellation: false,
                                        md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
                                        merchantName: "DBO MERCHANT FORA, Zubovskiy 2",
                                        merchantNameRus: "DBO MERCHANT FORA, Zubovskiy 2",
                                        opCode: 1,
                                        operationId: "909743",
                                        operationType: .debit,
                                        paymentDetailType: .betweenTheir,
                                        svgImage: .init(description: "string"),
                                        terminalCode: "41010601",
                                        tranDate: date,
                                        type: .inside)
        
        let expected = ServerCommands.DepositController.GetDepositStatement.Response(statusCode: .ok,
                                                                                     errorMessage: "string",
                                                                                     data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositStatement.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetDepositStatement_MinResponse_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "GetDepositStatementMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        
        let data = ProductStatementData(mcc: nil,
                                        accountId: nil,
                                        accountNumber: "70601810711002740401",
                                        amount: 144.21,
                                        cardTranNumber: nil,
                                        city: nil,
                                        comment: "Перевод денежных средств. НДС не облагается.",
                                        country: nil,
                                        currencyCodeNumeric: 810,
                                        date: date,
                                        deviceCode: nil,
                                        documentAmount: nil,
                                        documentId: nil,
                                        fastPayment: nil,
                                        groupName: "Прочие операции",
                                        isCancellation: nil,
                                        md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
                                        merchantName: nil,
                                        merchantNameRus: nil,
                                        opCode: nil,
                                        operationId: "123",
                                        operationType: .debit,
                                        paymentDetailType: .betweenTheir,
                                        svgImage: nil,
                                        terminalCode: nil,
                                        tranDate: nil,
                                        type: .inside)
        
        let expected = ServerCommands.DepositController.GetDepositStatement.Response(statusCode: .ok,
                                                                                     errorMessage: "string",
                                                                                     data: [data])
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositStatement.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - OpenDeposit
    
    func testOpenDeposit_Response_Decoding() throws {
        
        // given
        let url = bundle.url(forResource: "OpenDeposit", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let data = EmptyData()
        
        let expected = ServerCommands.DepositController.OpenDeposit.Response(statusCode: .ok,
                                                                             errorMessage: "string",
                                                                             data: data)
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.OpenDeposit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - SaveDepositName
    
    func testSaveDepositName_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "SaveDepositNameResponseGeneric", withExtension: "json") else {
            XCTFail("testSaveDepositName_Response_Decoding : Missing file: SaveDepositNameResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.DepositController.SaveDepositName.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.SaveDepositName.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: GetDepositProductList
    
    func testGetDepositProductList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetDepositProductListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetDepositProductList_Response_Decoding : Missing file: GetDepositProductListResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        
        guard let urlString = URL(string:"string") else { return }
        guard let _ = URL(string:"rest/getDepositImage?image=10000003006") else { return }
        
        let expected = ServerCommands.DepositController.GetDepositProductList.Response(
            statusCode: .ok,
            data: .init(
                list: [
                    .init(
                        depositProductID: 10000003006,
                        detailedСonditions: [
                            .init(desc: "Капитализация процентов ко вкладу", enable: true)
                        ],
                        documentsList: [
                            .init(name: "string", url: urlString)
                        ],
                        generalСondition:
                                .init(
                                    design: .init(
                                        background: [
                                            ColorData.init(description: "1C1C1C"),
                                            ColorData.init(description: "FFFFFF"),
                                            ColorData.init(description: "999999")
                                        ],
                                        textColor: [
                                            ColorData.init(description: "1C1C1C"),
                                            ColorData.init(description: "FFFFFF"),
                                            ColorData.init(description: "999999")
                                        ]
                                    ),
                                    formula: "(initialAmount * interestRate * termDay/AllDay) / 100",
                                    generalTxtСondition: ["string"],
                                    imageLink: "rest/getDepositImage?image=10000003006",
                                    maxRate: 8.7,
                                    maxSum: 10000000,
                                    maxTerm: 731,
                                    maxTermTxt: "До 2-х лет",
                                    minSum: 5000,
                                    minSumCur: "RUB",
                                    minTerm: 31),
                        name: "Сберегательный онлайн",
                        termRateList: [
                            .init(
                                termRateSum: [
                                    .init(
                                        sum: 5000,
                                        termRateList: [
                                            .init(
                                                rate: 0.7,
                                                term: 31,
                                                termName: "1 месяц",
                                                termABS: nil,
                                                termKind: nil,
                                                termType: nil
                                            )
                                        ]
                                    )
                                ],
                                сurrencyCode: "810",
                                сurrencyCodeTxt: "RUB"
                            )
                        ],
                        termRateCapList: nil,
                        txtСondition: ["string"])
                ],
                serial: "serial"),
            errorMessage: "string")
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositProductList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: GetCloseDeposit
    
    func testCloseDeposit_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "CloseDepositResponseGeneric", withExtension: "json") else {
            XCTFail("testCloseDeposit_Response_Decoding : Missing file: CloseDepositResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.DepositController.CloseDeposit.Response(statusCode: .ok, data: .init(paymentOperationDetailId: 1, documentStatus: .complete, accountNumber: "42317810000000000001", closeDate: 1, comment: "Закрытие срочного банковского вклада по договору № 04913_224RUB0000/22  от 22/04/2022. НДС не облагается.", category: "Закрытие вклада"), errorMessage: "string")
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.CloseDeposit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCloseDepositMin_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "CloseDepositResponseGenericMin", withExtension: "json") else {
            XCTFail("testCloseDeposit_Response_Decoding : Missing file: CloseDepositResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.DepositController.CloseDeposit.Response(statusCode: .ok, data: .init(paymentOperationDetailId: 18445, documentStatus: .complete, accountNumber: nil, closeDate: nil, comment: "Закрытие срочного банковского вклада по договору № 00080_224RUB4700/21  от 04/02/2021. НДС не облагается.", category: "Закрытие вклада"), errorMessage: nil)
        
        // when
        let result = try decoder.decode(ServerCommands.DepositController.CloseDeposit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCloseDepositUnknowStatus_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "CloseDepositResponseUnknowStatusGeneric", withExtension: "json") else {
            XCTFail("testCloseDeposit_Response_Decoding : Missing file: CloseDepositResponseUnknowStatusGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.DepositController.CloseDeposit.Response(statusCode: .ok, data: .init(paymentOperationDetailId: 1, documentStatus: .unknown, accountNumber: "42317810000000000001", closeDate: 1, comment: "Закрытие срочного банковского вклада по договору № 04913_224RUB0000/22  от 22/04/2022. НДС не облагается.", category: "Закрытие вклада"), errorMessage: "string")

        // when
        let result = try decoder.decode(ServerCommands.DepositController.CloseDeposit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    
    func testBeforeClosing_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "BeforeClosingResponseGeneric", withExtension: "json") else {
            XCTFail("testBeforeClosing_Response_Decoding : Missing file: BeforeClosingResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)

        let expected = ServerCommands.DepositController.GetDepositRestBeforeClosing.Response(statusCode: .ok, errorMessage: "string", data: 0)

        // when
        let result = try decoder.decode(ServerCommands.DepositController.GetDepositRestBeforeClosing.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

extension Date {
    
    static func date(from value: String, formatter: DateFormatter) throws -> Date {
        
        guard let date = formatter.date(from: value) else {
            throw DateFormattingError.unableCreateDateFrom(value)
        }
        
        return date
    }
    
    enum DateFormattingError: Error {
        case unableCreateDateFrom(String)
    }
}


