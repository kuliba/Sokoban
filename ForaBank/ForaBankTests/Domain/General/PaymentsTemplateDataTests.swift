//
//  PaymentsTemplateDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 01.06.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsTemplateDataTests: XCTestCase {
    
    typealias Kind = PaymentTemplateData.Kind
    typealias Me2MeData = TransferMe2MeData
    typealias GeneralData = TransferGeneralData
    
    func test_paymentsTemplate_insideByPhonePhoneNumber_empty() throws {
        
        // given
        let type = Kind.mobile
        let transferData = TransferMe2MeData.me2MeStub()
        
        let template = PaymentTemplateData.templateStub(type: type,
                                                        parameterList: transferData)
        let insideByPhonePhoneNumber = template.phoneNumber
        
        XCTAssertNil(insideByPhonePhoneNumber)
    }
    
    func test_paymentsTemplate_insideByPhonePhoneNumber() throws {
        
        // given
        let type = Kind.mobile
        let transferData = TransferGeneralData.generalStub()
        
        let template = PaymentTemplateData.templateStub(type: type,
                                                        parameterList: transferData)
        let insideByPhonePhoneNumber = template.phoneNumber
        
        XCTAssertNotNil(insideByPhonePhoneNumber)
        XCTAssertEqual(
            insideByPhonePhoneNumber,
            "number")
    }
    
    func test_paymentsTemplate_insideByPhoneBankId() throws {
        
        // given
        let type = Kind.mobile
        let transferData = TransferGeneralData.generalStub()
        
        let template = PaymentTemplateData.templateStub(type: type,
                                                        parameterList: transferData)
        let insideByPhoneBankId = template.foraBankId
        
        XCTAssertNotNil(insideByPhoneBankId)
        XCTAssertEqual(
            insideByPhoneBankId,
            "100000000217")
    }
    
    func test_paymentsTemplate_insideByPhoneBankId_nil() throws {
        
        // given
        let type = Kind.mobile
        let transferData = TransferMe2MeData.me2MeStub()
        let template = PaymentTemplateData.templateStub(type: type,
                                                        parameterList: transferData)
        let insideByPhoneBankId = template.foraBankId
        
        XCTAssertNil(insideByPhoneBankId)
    }
}
