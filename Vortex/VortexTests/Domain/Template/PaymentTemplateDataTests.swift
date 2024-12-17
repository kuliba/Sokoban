//
//  PaymentTemplateDataTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.09.2023.
//

@testable import ForaBank
import XCTest

final class PaymentTemplateDataTests: XCTestCase {
    
    func test_payerProductId_shouldReturnNilOnNilPayer() {
        
        let data = templateStub(payer: nil)
        
        XCTAssertNil(data.payerProductId)
    }
    
    func test_payerProductId_shouldReturnNil_onNilAccountID() {
        
        let data = templateStub(payer: .test(accountId: nil))
        
        XCTAssertNil(data.payerProductId)
    }
    
    func test_payerProductId_shouldReturnNil_onNilCardID() {
        
        let data = templateStub(payer: .test(cardId: nil))
        
        XCTAssertNil(data.payerProductId)
    }
    
    func test_payerProductId_shouldReturnAccountID() {
        
        let data = templateStub(payer: .test(accountId: 12345))
        
        XCTAssertNoDiff(data.payerProductId, 12345)
    }
    
    func test_payerProductId_shouldReturnCardID() {
        
        let data = templateStub(payer: .test(accountId: nil, cardId: 12345))
        
        XCTAssertNoDiff(data.payerProductId, 12345)
    }
    
    func test_payerProductId_shouldReturnAccountID_onNonNilCardID() {
        
        let data = templateStub(payer: .test(accountId: 12345, cardId: 54321))
        
        XCTAssertNoDiff(data.payerProductId, 12345)
    }
    
    func test_payerProductId_shouldReturnLast() {
        
        let lastAccountID = 12345
        let data = templateStub(payer: .test(accountId: lastAccountID))
        
        XCTAssertNoDiff(data.payerProductId, lastAccountID)
        XCTAssertNoDiff(data.parameterList.map(\.payer?.accountId), [
            12, lastAccountID
        ])
    }
    
    //MARK: Computed Property
    
    func test_sfp_recipientID_shouldReturnValue() {
        
        let stub = Model.templateSFPStub([
            Model.anywayTransferDataStub(
                [.init(fieldid: 1, fieldname: "RecipientID", fieldvalue: "123")])
        ])
        
        XCTAssertNoDiff(stub.sfpPhone, "123")
    }
    
    func test_sfp_recipientID_shouldReturnNil() {
        
        let stub = Model.templateSFPStub([])
        XCTAssertNoDiff(stub.sfpPhone, nil)
    }
    
    // MARK: - Helpers
    
    private func templateStub(
        payer: TransferData.Payer?
    ) -> PaymentTemplateData {
        
        .templateStub(
            type: .betweenTheir,
            parameterList: [
                .init(
                    amount: 123,
                    check: true,
                    comment: nil,
                    currencyAmount: "RUB",
                    payer: .test(accountId: 12)
                ),
                .init(
                    amount: 123,
                    check: true,
                    comment: nil,
                    currencyAmount: "RUB",
                    payer: payer
                )
            ]
        )
    }
}
