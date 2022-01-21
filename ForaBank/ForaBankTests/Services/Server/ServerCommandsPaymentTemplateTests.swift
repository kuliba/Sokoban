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
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
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
    
    func testGetPaymentTemplateList_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetPaymentTemplateListResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let payer = TransferAbstract.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let transfer = Transfer(amount: nil, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        let paymentTemplate = PaymentTemplateData(groupName: "Переводы СБП", name: "Иванов Иван Иванович", parameterList: [transfer], paymentTemplateId: 1, sort: 1, svgImage: SVGImageData(description: "string"), type: .sfp)
        let expected = ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response(statusCode: .ok, errorMessage: "string", data: [paymentTemplate])
        
        // when
        let result = try decoder.decode(ServerCommands.PaymentTemplateController.GetPaymentTemplateList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
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
        let payer = TransferAbstract.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let transfer = Transfer(amount: nil, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
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
