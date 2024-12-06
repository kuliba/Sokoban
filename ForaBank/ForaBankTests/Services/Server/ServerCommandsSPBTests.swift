//
//  ServerCommandsSPBTests.swift
//  VortexTests
//
//  Created by Max Gribov on 30.01.2023.
//

@testable import ForaBank
import ServerAgent
import XCTest

class ServerCommandsSPBTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsSPBTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetScenarioQRData

    func testGetScenarioQRData_Response_Decoding() throws {
       
        // given
        guard let url = bundle.url(forResource: "GetScenarioQRDataGeneric", withExtension: "json") else {
            XCTFail("testGetScenarioQRData_Response_Decoding : Missing file: GetScenarioQRDataGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        
        // then
       XCTAssertNoThrow(try decoder.decode(ServerCommands.SBPController.GetScenarioQRData.Response.self, from: json))
    }
}

extension ServerCommandsSPBTests {
    
    // MARK: - getScenarioQRData
    
    /// 1.1. Привязка счета
    /// 1.1.1. Пример успешного ответа. Не требуется подключение договора СБП
    ///
    /// - Warning: contracts as of May 3, 2023
    func test_getScenarioQRData_1_1_1_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_1_1_1"
        )
        
        XCTAssertEqual(responseData.parameters.count, 6)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "brandName", "debit_account", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 1.1. Привязка счета
    /// 1.1.1. Пример успешного ответа. Не требуется подключение договора СБП
    ///
    /// - Warning: contracts as of May 3, 2023 where tweaked:
    ///     `"color": "RED",` was changed to `"color": "red",`
    ///     `"color": "GRAY",` was changed to `"color": "white",`
    func test_getScenarioQRData_1_1_1_tweaked_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_1_1_1_tweaked"
        )
        
        XCTAssertEqual(responseData.parameters.count, 6)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "brandName", "debit_account", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 1.1. Привязка счета
    /// 1.1.2. Пример успешного ответа. Требуется подключение договора СБП
    ///
    func test_getScenarioQRData_1_1_2_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_1_1_2"
        )
        
        XCTAssertEqual(responseData.parameters.count, 7)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "brandName", "debit_account", "terms_check", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 1.2. Оплата
    /// 1.2.1. Указана сумма перевода
    ///
    func test_getScenarioQRData_1_2_1_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_1_2_1"
        )
        
        XCTAssertEqual(responseData.parameters.count, 9)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "debit_account", "brandName", "paymentPurpose", "amount", "recipientBank", "terms_check", "button_pay", "sfp_logo"])
    }
    
    /// 1.2. Оплата
    /// 1.2.2. Не указана сумма перевода (клиент вводит ее вручную)
    ///
    func test_getScenarioQRData_1_2_2_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_1_2_2"
        )
        
        XCTAssertEqual(responseData.parameters.count, 7)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "debit_account", "brandName", "paymentPurpose", "recipientBank", "sfp_logo", "payment_amount"])
    }
    
    // TODO: other getScenarioQRData cases
    
    // MARK: - createC2BPaymentCard
    
    /// 4.1. Оплата с привязкой
    ///
    func test_createC2BPaymentCard_4_1_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentCard.Response.self,
            from: "createC2BPaymentCard_4_1"
        )
     
        XCTAssertEqual(responseData.parameters.count, 11)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "debit_account", "success_link_message", "success_option_buttons", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 4.2. Оплата без привязки
    ///
    func test_createC2BPaymentCard_4_2_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentCard.Response.self,
            from: "createC2BPaymentCard_4_2"
        )
     
        XCTAssertEqual(responseData.parameters.count, 8)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "success_option_buttons", "button_pay", "sfp_logo"])
    }
    
    func test_createC2BPaymentCard_5_0_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentCard.Response.self,
            from: "createC2BPaymentCard_5_0"
        )
     
        XCTAssertEqual(responseData.parameters.count, 10)
        XCTAssertEqual(responseData.parameters.map(\.id), ["paymentOperationDetailId", "printFormType", "success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "success_option_buttons", "button_main", "sfp_logo"])
    }
    
    // MARK: - createC2BPaymentAcc

    /// 5.1. Оплата с привязкой
    ///
    /// - Warning: contracts as of May 3, 2023
    func test_createC2BPaymentAcc_5_1_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentAcc.Response.self,
            from: "createC2BPaymentAcc_5_1"
        )
        
        XCTAssertEqual(responseData.parameters.count, 11)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "debit_account", "success_link_message", "success_option_buttons", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 5.1. Оплата с привязкой
    ///
    /// - Warning: contracts as of May 3, 2023 where tweaked:
    ///     `"color": "RED",` was changed to `"color": "red",`
    ///     `"color": "WHITE",` was changed to `"color": "white",`
    func test_createC2BPaymentAcc_5_1_tweaked_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentAcc.Response.self,
            from: "createC2BPaymentAcc_5_1_tweaked"
        )
        
        XCTAssertEqual(responseData.parameters.count, 11)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "debit_account", "success_link_message", "success_option_buttons", "button_save", "button_cancel", "sfp_logo"])
    }
    
    /// 5.2. Оплата без привязки
    ///
    /// - Warning: contracts as of May 3, 2023
    func test_createC2BPaymentAcc_5_2_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentAcc.Response.self,
            from: "createC2BPaymentAcc_5_2"
        )
        
        XCTAssertEqual(responseData.parameters.count, 8)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "success_option_buttons", "button_pay", "sfp_logo"])
    }
    
    /// 5.2. Оплата без привязки
    ///
    /// - Warning: contracts as of May 3, 2023 where tweaked:
    ///     `"color": "RED",` was changed to `"color": "red",`
    func test_createC2BPaymentAcc_5_2_tweaked_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPPaymentController.CreateC2BPaymentAcc.Response.self,
            from: "createC2BPaymentAcc_5_2_tweaked"
        )
        
        XCTAssertEqual(responseData.parameters.count, 8)
        XCTAssertEqual(responseData.parameters.map(\.id), ["success_status", "success_title", "success_amount", "brandName", "redirect_store_link", "success_option_buttons", "button_pay", "sfp_logo"])
    }
    
    // unsupported parameters in json data, but all supported shold correctly decoded
    func test_getScenarioQRData_6_0_shouldDecode_onlySupportedParameters() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SBPController.GetScenarioQRData.Response.self,
            from: "getScenarioQRData_6_0"
        )
        
        XCTAssertEqual(responseData.parameters.count, 6)
        XCTAssertEqual(responseData.parameters.map(\.id), ["title", "brandName", "debit_account", "button_save", "button_cancel", "sfp_logo"])
    }
    
    // MARK: - confirmC2BSubCard
    
    func test_confirmC2BSubCard_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SubscriptionController.ConfirmC2BSubCard.Response.self,
            from: "confirmC2BSubCard"
        )
     
        XCTAssertEqual(responseData.operationStatus, .complete)
        XCTAssertEqual(responseData.title, "Привязка счета оформлена")
        XCTAssertEqual(responseData.brandIcon, "c896aba73a67de2bfc69de70209eb3f3")
        XCTAssertEqual(responseData.brandName, "Тестовый ТСП ТИВ")
        XCTAssertEqual(responseData.redirectUrl, .init(string: "https://sbp.nspk.ru/test_link_tiv.html")!)
    }
    
    // MARK: - confirmC2BSubAcc
    
    func test_confirmC2BSubAcc_shouldDecode() throws {
        
        let responseData = try decodeResponseData(
            ServerCommands.SubscriptionController.ConfirmC2BSubAcc.Response.self,
            from: "confirmC2BSubAcc"
        )
     
        XCTAssertEqual(responseData.operationStatus, .complete)
        XCTAssertEqual(responseData.title, "Привязка счета оформлена")
        XCTAssertEqual(responseData.brandIcon, "c896aba73a67de2bfc69de70209eb3f3")
        XCTAssertEqual(responseData.brandName, "Тестовый ТСП ТИВ")
        XCTAssertEqual(responseData.redirectUrl, .init(string: "https://sbp.nspk.ru/test_link_tiv.html")!)
    }
    
    // MARK: - Helpers
    
    private func decodeResponseData<T: ServerResponse>(
        _ type: T.Type,
        from filename: String,
        decoder: JSONDecoder = .serverDate,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Payload {
        
        do {
            let json = try getJSON(from: filename, file: file, line: line)
            let response = try decoder.decode(T.self, from: json)
            
            XCTAssertEqual(response.statusCode, .ok, "Expected Server Status Code \"ok\", got \"\(response.statusCode)\" instead.", file: file, line: line)
            XCTAssertEqual(response.errorMessage, nil, "Expected nil error message, got \"\(response.errorMessage ?? "")\" instead.", file: file, line: line)
            
            return try XCTUnwrap(response.data, file: file, line: line)
            
        } catch {
            XCTFail("Got error \"\(error)\"", file: file, line: line)
            throw error
        }
    }
}
