//
//  CreateAnywayTransferHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class CreateAnywayTransferHelpersTests: XCTestCase {
    
    typealias AnywayTransfer = ServerCommands.TransferController.CreateAnywayTransfer
    typealias Request = AnywayTransfer.Payload
    typealias Response = AnywayTransfer.Response
    
    // MARK: - iFora 4285 9rub
    
    func test_createAnywayTransfer_iFora_4285_9rub_request() throws {
        
        let request: Request = .iFora_4285_9rub
        
        XCTAssertEqual(request.puref, "iFora||4285")
        XCTAssertEqual(request.amount, 9)
        XCTAssertEqual(request.payer.cardId, 10000184510)
        XCTAssertEqual(request.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(request.phoneNumber, "9039999999")
    }
    
    func test_createAnywayTransfer_iFora_4285_9rub_response() throws {
        
        let response: Response = .iFora_4285_9rub
        
        XCTAssertEqual(response.statusCode, .serverError)
        XCTAssertEqual(response.errorMessage, "Некорректный ввод данных (проверьте сумму) (код 1001)")
        XCTAssertEqual(response.data, nil)
    }
    
    // MARK: - iFora 4285 10rub
    
    func test_createAnywayTransfer_iFora_4285_10rub_request() throws {
        
        let request: Request = .iFora_4285_10rub
        
        XCTAssertEqual(request.puref, "iFora||4285")
        XCTAssertEqual(request.amount, 10)
        XCTAssertEqual(request.payer.cardId, 10000184510)
        XCTAssertEqual(request.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(request.phoneNumber, "9039999999")
    }
    
    func test_createAnywayTransfer_iFora_4285_10rub_response() throws {
        
        let response: Response = .iFora_4285_10rub
        
        XCTAssertEqual(response.statusCode, .ok)
        XCTAssertNil(response.errorMessage)
        XCTAssertEqual(response.data?.amount, 10)
        XCTAssertEqual(response.data?.additionalList.first?.fieldName, "a3_NUMBER_1_2")
        XCTAssertEqual(response.phoneNumber, "9039999999")
        XCTAssertEqual(response.data?.additionalList.first?.fieldTitle, "Номер телефона (без +7):")
        XCTAssertEqual(response.data?.additionalList.last?.fieldName, "a3_AMOUNT_2_2")
        XCTAssertEqual(response.data?.additionalList.last?.fieldValue, "10.0")
        XCTAssertEqual(response.data?.additionalList.last?.fieldTitle, "Сумма, руб.:")
    }
    
    // MARK: - iFora 4286
    
    func test_createAnywayTransfer_iFora_4286_request() throws {
        
        let request: Request = .iFora_4286
        
        XCTAssertEqual(request.puref, "iFora||4286")
        XCTAssertEqual(request.amount, 1)
        XCTAssertEqual(request.payer.cardId, 10000184510)
        XCTAssertEqual(request.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(request.phoneNumber, "9191619658")
    }
    
    func test_createAnywayTransfer_iFora_4286_response() throws {
        
        let response: Response = .iFora_4286
        
        XCTAssertEqual(response.statusCode, .ok)
        XCTAssertNil(response.errorMessage)
        XCTAssertEqual(response.data?.amount, 1)
        XCTAssertEqual(response.data?.additionalList.first?.fieldName, "a3_NUMBER_1_2")
        XCTAssertEqual(response.phoneNumber, "9191619658")
        XCTAssertEqual(response.data?.additionalList.first?.fieldTitle, "Номер телефона (без +7)")
        XCTAssertEqual(response.data?.additionalList.last?.fieldName, "a3_AMOUNT_3_2")
        XCTAssertEqual(response.data?.additionalList.last?.fieldValue, "1.0")
        XCTAssertEqual(response.data?.additionalList.last?.fieldTitle, "Сумма")
    }
    
    // MARK: - iFora 515A3 1rub
    
    func test_createAnywayTransfer_iFora_515A3_1rub_request() throws {
        
        let request: Request = .iFora_515A3_1rub
        
        XCTAssertEqual(request.puref, "iFora||515A3")
        XCTAssertEqual(request.amount, 1)
        XCTAssertEqual(request.payer.cardId, 10000184510)
        XCTAssertEqual(request.operatorID, "a3_code_1_1_1")
        XCTAssertEqual(request.phoneNumber, "9999679969")
    }
    
    func test_createAnywayTransfer_iFora_515A3_1rub_response() throws {
        
        let response: Response = .iFora_515A3_1rub
        
        XCTAssertEqual(response.statusCode, .serverError)
        XCTAssertEqual(response.errorMessage, "Сумма платежа не соответствует требованиям Получателя (код 1001)")
        XCTAssertEqual(response.data, nil)
    }
    
    // MARK: - iFora 515A3 10rub
    
    func test_createAnywayTransfer_iFora_515A3_10rub_request() throws {
        
        let request: Request = .iFora_515A3_10rub
        
        XCTAssertEqual(request.puref, "iFora||515A3")
        XCTAssertEqual(request.amount, 10)
        XCTAssertEqual(request.payer.cardId, 10000184510)
        XCTAssertEqual(request.operatorID, "a3_code_1_1_1")
        XCTAssertEqual(request.phoneNumber, "9999679969")
    }
    
    func test_createAnywayTransfer_iFora_515A3_10rub_response() throws {
        
        let response: Response = .iFora_515A3_10rub
        
        XCTAssertEqual(response.statusCode, .ok)
        XCTAssertNil(response.errorMessage)
        XCTAssertEqual(response.data?.amount, 10)
        XCTAssertEqual(response.data?.additionalList.first?.fieldName, "a3_code_1_1_1")
        XCTAssertEqual(response.phoneNumber, "9999679969")
        XCTAssertEqual(response.data?.additionalList.first?.fieldTitle, "Номер телефона +7:")
        XCTAssertEqual(response.data?.additionalList.last?.fieldName, "a3_sum_2_1")
        XCTAssertEqual(response.data?.additionalList.last?.fieldValue, "10.0")
        XCTAssertEqual(response.data?.additionalList.last?.fieldTitle, "Сумма к оплате, руб.:")
    }
}

// MARK: - DSL

extension ServerCommands.TransferController.CreateAnywayTransfer.Payload {
    
    var phoneNumber: String? { additional.first?.fieldvalue }
    var operatorID: String? { additional.first?.fieldname }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Response {
    
    var phoneNumber: String? { data?.additionalList.first?.fieldValue }
}
