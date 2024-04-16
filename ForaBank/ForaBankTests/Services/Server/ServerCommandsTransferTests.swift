//
//  ServerCommandsTransferTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsTransferTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsTransferTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
    //MARK: - AntiFraud
    
    func testAntiFraud_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "AntiFraudResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.AntiFraud.Response(statusCode: .ok, errorMessage: "string", data: false)
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.AntiFraud.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - ChangeOutgoing
    
    func testChangeOutgoing_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "ChangeOutgoingResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.ChangeOutgoing.Response(statusCode: .ok, errorMessage: "string", data: .init(paymentOperationDetailId: 1))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.ChangeOutgoing.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CheckCard
    
    func testCheckCard_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CheckCardResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CheckCard.Response(statusCode: .ok, errorMessage: "string", data: .init(check: true, payeeCurrency: "RUB"))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CheckCard.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateAnywayTransfer
    
    func testCreateAnywayTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateAnywayTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateAnywayTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 100, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: .init(description: "string"), typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", inputFieldType: .phone, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: .init(description: "string"), viewType: .input)], scenario: .ok))

        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateAnywayTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateAnywayTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateAnywayTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateAnywayTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: nil, typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: nil, needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateAnywayTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateContactAddresslessTransfer
    
    func testCreateContactAddresslessTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateContactAddresslessTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateContactAddresslessTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 100, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: .init(description: "string"), typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: .init(description: "string"), viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateContactAddresslessTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateContactAddresslessTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateContactAddresslessTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateContactAddresslessTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: nil, typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: nil, needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateContactAddresslessTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateDirectTransfer
    
    func testCreateDirectTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateDirectTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateDirectTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 100, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: .init(description: "string"), typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: .init(description: "string"), viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateDirectTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateDirectTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateContactAddresslessTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateDirectTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: nil, typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: nil, needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateDirectTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateMe2MePullCreditTransfer
    
    func testCreateMe2MePullCreditTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateMe2MePullCreditTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateMe2MePullCreditTransfer.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateMe2MePullCreditTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateMe2MePullDebitTransfer
    
    func testCreateMe2MePullDebitTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateMe2MePullDebitTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateMe2MePullDebitTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 100, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: .init(description: "string"), typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: .init(description: "string"), viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateMe2MePullDebitTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateMe2MePullDebitTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateMe2MePullDebitTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateMe2MePullDebitTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: nil, typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: nil, needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateMe2MePullDebitTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateSFPTransfer
    
    func testCreateSFPTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateSFPTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateSFPTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 100, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: .init(description: "string"), typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: "account", dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: "+7(___)-___-__-__", maxLength: 10, minLength: 0, order: 2, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: "Пример: 9051111111", title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: .init(description: "string"), viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateSFPTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateSFPTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateSFPTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateSFPTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, additionalList: [.init(fieldName: "a3_PERSONAL_ACCOUNT_5_5", fieldTitle: "Лицевой счет у Получателя", fieldValue: "1234567890", svgImage: nil, typeIdParameterList: nil, recycle: nil)], finalStep: false, infoMessage: nil, needSum: false, printFormType: nil, parameterListForNextStep: [.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: nil, isRequired: true, mask: "+7(___)-___-__-__", maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "Input", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)], scenario: .ok))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateSFPTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateTransfer
    
    func testCreateTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: 100, creditAmount: 100, currencyAmount: .init(description: "RUB"), currencyPayee: .init(description: "RUB"), currencyPayer: .init(description: "RUB"), currencyRate: 86.7, debitAmount: 100, fee: 00, needMake: true, needOTP: true, payeeName: "Иван Иванович И.", documentStatus: .complete, paymentOperationDetailId: 1, scenario: nil))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testCreateTransfer_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "CreateTransferResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.CreateTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: nil, paymentOperationDetailId: 1, scenario: nil))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetVerificationCode
    
    func testGetVerificationCode_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetVerificationCodeResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.GetVerificationCode.Response(statusCode: .ok, errorMessage: "string", data: .init(otp: "123456", resendOTPCount: 5))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.GetVerificationCode.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetVerificationCode_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetVerificationCodeResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.GetVerificationCode.Response(statusCode: .ok, errorMessage: "string", data: .init(otp: nil, resendOTPCount: 5))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.GetVerificationCode.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - IsSingleService
    
    func testIsSingleService_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "IsSingleServiceResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.IsSingleService.Response(statusCode: .ok, errorMessage: "string", data: false)
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.IsSingleService.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - MakeTransfer
    
    func testMakeTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "MakeTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.MakeTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(documentStatus: .complete, paymentOperationDetailId: 1))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.MakeTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testMakeTransfer_ResponsAnyway_Decoding() throws {

        // given
        let url = bundle.url(forResource: "MakeAnywayTransferResponseMax", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let transferAnywayResponse = TransferAnywayResponseData(amount: 100, creditAmount: 100, currencyAmount: Currency(description: "RUB"), currencyPayee: Currency(description: "RUB"), currencyPayer: Currency(description: "RUB"), currencyRate: 87.5, debitAmount: 100, fee: 5, needMake: true, needOTP: false, payeeName: "Иван Иванович", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [], finalStep: true, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: [], scenario: .ok)
        let expected = ServerCommands.TransferController.MakeTransfer.Response(statusCode: .ok, errorMessage: "string", data: transferAnywayResponse)
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.MakeTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - ReturnOutgoing
    
    func testReturnOutgoing_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "ReturnOutgoingResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.TransferController.ReturnOutgoing.Response(statusCode: .ok, errorMessage: "string", data: .init(paymentOperationDetailId: 1))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.ReturnOutgoing.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateInterestDepositTransfer
    
    func testCreateInterestDepositTransfer_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "CreateInterestDepositTransferResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.TransferController.CreateInterestDepositTransfer.Response(statusCode: .ok, errorMessage: "string", data: .init(needMake: true, needOTP: true, amount: 100.02, creditAmount: 100.02, fee: 100, currencyAmount: "100.02", currencyPayer: "RUB", currencyPayee: "RUB", currencyRate: 86.7, debitAmount: 100, payeeName: "Иван Иванович И.", paymentOperationDetailId: 1, documentStatus: .complete))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.CreateInterestDepositTransfer.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - TransferLimit
    
    func testTransferLimitData_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "TransferLimitGenegic", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.TransferController.GetTransferLimit.Response(statusCode: .ok, errorMessage: "string", data: .init(limit: 1000000, currencyLimit: "RUB"))
        
        // when
        let result = try decoder.decode(ServerCommands.TransferController.GetTransferLimit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
