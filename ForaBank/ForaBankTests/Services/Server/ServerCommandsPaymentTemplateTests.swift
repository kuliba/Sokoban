//
//  ServerCommandsPaymentTemplateTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class ServerCommandsPaymentTemplateTests: XCTestCase {
    
    let bundle = Bundle(for: PaymentTemplateTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
    //MARK: - DeletePaymentTemplates

    func testDeletePaymentTemplates_Payload_Encoding() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.DeletePaymentTemplates(token:"", payload: .init(paymentTemplateIdList: [1, 2, 3]))
        let expected = "{\"paymentTemplateIdList\":[1,2,3]}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testDeletePaymentTemplates_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "DeletePaymentTemplatesResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PaymentTemplateController.DeletePaymentTemplates.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.DeletePaymentTemplates.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetPaymentTemplateList
    
    func testGetPaymentTemplateList_Payload_Encoding() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList(token: "")
        
        // then
        XCTAssertNil(command.payload)
    }
    
    //TODO: - Complete data tests
    func testGetPaymentTemplateList_ServerResponse_Decoding() throws {

        // given
        let url = bundle.url(forResource: "PaymentsTemplateListGenericResponse", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: 10000184511, cardNumber: nil, phoneNumber: nil)
        let amount: Double?  = nil
        let parameter1 = TransferAnywayData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, additional: [.init(fieldid: 1, fieldname: "trnPickupPoint", fieldvalue: "AM")], puref: "iFora||MIG")
        
        let parameter2 = TransferAnywayData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, additional: [.init(fieldid: 1, fieldname: "trnPickupPoint", fieldvalue: "AM"), .init(fieldid: 2, fieldname: "DIRECT_BANKS", fieldvalue: "iFora||TransferEvocaClient12")], puref: "iFora||MIG")
        
        let parameter3 = TransferAnywayData(amount: 100.05, check: false, comment: nil, currencyAmount: "RUB", payer: payer, additional: [.init(fieldid: 1, fieldname: "trnPickupPoint", fieldvalue: "AM"), .init(fieldid: 2, fieldname: "DIRECT_BANKS", fieldvalue: "iFora||TransferEvocaClient12"), .init(fieldid: 3, fieldname: "RECP", fieldvalue: "+37496127188"), .init(fieldid: 4, fieldname: "##CURR", fieldvalue: "RUB")], puref: "iFora||MIG")
        
        let paymentTemplate = PaymentTemplateData.init(groupName: "Перевод МИГ", name: "Перевод между счетами", parameterList: [parameter1, parameter2, parameter3], paymentTemplateId: 2513, productTemplate: nil, sort: 4, svgImage: .init(description: "image"), type: .newDirect)
        
        let expected = ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response(statusCode: .ok, errorMessage: nil, data: [paymentTemplate])
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetPaymentTemplateList_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetPaymentTemplateListResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: 10000184511, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferGeneralData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        let paymentTemplate = PaymentTemplateData(groupName: "Переводы СБП", name: "Иванов Иван Иванович", parameterList: [transfer], paymentTemplateId: 1, productTemplate: .init(currency: "RUB", customName: "Новая карта", id: 1, numberMask: "4444 **** **** 1234", paymentSystemImage: .init(description: "string"), smallDesign: .init(description: "string"), type: .card), sort: 1, svgImage: SVGImageData(description: "string"), type: .sfp)
        let expected = ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response(statusCode: .ok, errorMessage: "string", data: [paymentTemplate])
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetPaymentTemplateList_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetPaymentTemplateListResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferGeneralData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        let paymentTemplate = PaymentTemplateData(groupName: "Переводы СБП", name: "Иванов Иван Иванович", parameterList: [transfer], paymentTemplateId: 1, productTemplate: nil, sort: 1, svgImage: SVGImageData(description: "string"), type: .sfp)
        let expected = ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response(statusCode: .ok, errorMessage: "string", data: [paymentTemplate])
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetPaymentTemplateList_Response_SFP_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetPeymentTemlpateListResponseSFP", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response.self, from: json)
        
        // then
        XCTAssert(result.data?.first?.parameterList.first is TransferAnywayData)
    }
    
    //MARK: - SavePaymentTemplate
    
    func testSavePaymentTemplate_Payload_Encoding() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.SavePaymentTemplate(token: "", payload: .init(name: "test", paymentOperationDetailId: 1))
        let expected = "{\"name\":\"test\",\"paymentOperationDetailId\":1}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testSavePaymentTemplate_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "SavePaymentTemplateResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PaymentTemplateController.SavePaymentTemplate.Response(statusCode: .ok, errorMessage: "string", data: .init(paymentTemplateId: 1))
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.SavePaymentTemplate.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - SortingPaymentTemplates
    
    func testSortingPaymentTemplates_Payload_Encoding() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.SortingPaymentTemplates(token: "", payload: .init(sortDataList: [.init(paymentTemplateId: 1, sort: 1)]))
        let expected = "{\"sortDataList\":[{\"paymentTemplateId\":1,\"sort\":1}]}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testSortingPaymentTemplates_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "SortingPaymentTemplatesResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PaymentTemplateController.SortingPaymentTemplates.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.SortingPaymentTemplates.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - UpdatePaymentTemplate
    
    func testUpdatePaymentTemplate_Payload_Encoding() throws {

        // given
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferGeneralData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        let command = ServerCommands.PaymentTemplateController.UpdatePaymentTemplate(token: "", payload: .init(name: "test", parameterList: [transfer], paymentTemplateId: 1))
        let expected = "{\"name\":\"test\",\"paymentTemplateId\":1,\"parameterList\":[{\"amount\":null,\"currencyAmount\":\"RUB\",\"check\":false,\"payeeInternal\":null,\"comment\":null,\"payer\":{},\"payeeExternal\":null}]}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testUpdatePaymentTemplate_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "UpdatePaymentTemplateResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PaymentTemplateController.UpdatePaymentTemplate.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.UpdatePaymentTemplate.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
