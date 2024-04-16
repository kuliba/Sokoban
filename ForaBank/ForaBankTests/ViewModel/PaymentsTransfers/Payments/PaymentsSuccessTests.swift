//
//  PaymentsSuccessTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 20.09.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSuccessTests: XCTestCase {
    
    // MARK: Payments Success meToMe Mode
    
    func test_init_paymentsSuccess_withMeToMeMode_shouldReturnPaymentSuccess() {
        
        let sut = makeSUT(mode: meToMeMode(
            documentStatus: .complete
        ))
        
        XCTAssertNotNil(sut)
        XCTAssertNoDiff(sut?.status, .complete)
    }
    
    func test_init_paymentsSuccess_withMeToMeModeDocumentStatusNil_shouldReturnNil() {
        
        let sut = makeSUT(mode: meToMeMode(
            documentStatus: nil
        ))
        
        XCTAssertNil(sut)
    }
    
    // MARK: Payments Success makePaymentToDeposit Mode
    
    func test_init_paymentsSuccess_withMakePaymentToDepositDocumentStatusNil_shouldReturnNil() {
        
        let sut = makeSUT(mode: makePaymentToDeposit(
            documentStatus: nil
        ))
        
        XCTAssertNil(sut)
    }
    
    func test_init_paymentsSuccess_withMakePaymentFromDepositMode_shouldReturnPaymentSuccess() {
        
        let sut = makeSUT(mode: makePaymentToDeposit(
            documentStatus: .complete
        ))
        
        XCTAssertNotNil(sut)
        XCTAssertNoDiff(sut?.status, .complete)
    }
    
    // MARK: Payments Success makePaymentFromDeposit Mode
    
    func test_init_paymentsSuccess_withMakePaymentFromDepositDocumentStatusNil_shouldReturnNil() {
        
        let sut = makeSUT(mode: makePaymentFromDeposit(
            documentStatus: nil
        ))
        
        XCTAssertNil(sut)
    }
    
    func test_init_paymentsSuccess_withMakePaymentToDepositMode_shouldReturnPaymentSuccess() {
        
        let sut = makeSUT(mode: makePaymentFromDeposit(
            documentStatus: .complete
        ))
        
        XCTAssertNotNil(sut)
        XCTAssertNoDiff(sut?.status, .complete)
    }
    
    // MARK: Payments Success closeAccount Mode
    
    func test_init_paymentsSuccess_withCloseAccount_shouldReturnNotNil() {
        
        let sut = makeSUT(mode: closeAccount())
        
        XCTAssertNotNil(sut)
    }
    
    // MARK: Payments Success closeAccountEmpty Mode
    
    func test_init_paymentsSuccess_withCloseAccountEmpty_shouldReturnNotNil() {
        
        let sut = makeSUT(mode: closeAccountEmpty())
        
        XCTAssertNotNil(sut)
    }
    
    // MARK: Payments Success closeDeposit Mode
    
    func test_init_paymentsSuccess_withCloseDeposit_shouldReturnNotNil() {
        
        let sut = makeSUT(mode: closeDeposit())
        
        XCTAssertNotNil(sut)
    }
    
    func test_init_paymentsSuccess_withNormalMode_shouldReturnNil() {
        
        let sut = makeSUT(mode: .normal)
        
        XCTAssertNil(sut)
    }
    
    // MARK: Helpers
    
    func makeSUT(
        mode: PaymentsSuccessViewModel.Mode,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Payments.Success? {
        
        let model = Model.mockWithEmptyExcept()
        let sut = Payments.Success(
            model: model,
            mode: mode,
            amountFormatter:
                model.amountFormatted(amount:currencyCode:style:)
        )
        
        trackForMemoryLeaks(model, file: file, line: line)
        return sut
    }
    
    func closeDeposit() -> PaymentsSuccessViewModel.Mode {
        
        .closeDeposit(.rub, balance: 100, makeCloseProductTransferData())
    }
    
    func closeAccountEmpty() -> PaymentsSuccessViewModel.Mode {
        
        .closeAccountEmpty(
            1, .rub, balance: 100, makeCloseProductTransferData())
    }
    
    func closeAccount() -> PaymentsSuccessViewModel.Mode {
        
        .closeAccount(
            1, .rub, balance: 100, makeCloseProductTransferData())
    }
    
    func makeCloseProductTransferData() -> CloseProductTransferData {
        
        .init(
            paymentOperationDetailId: 1,
            documentStatus: .complete,
            accountNumber: nil,
            closeDate: nil,
            comment: nil,
            category: nil
        )
    }
    
    func makePaymentFromDeposit(
        documentStatus: TransferResponseData.DocumentStatus?
    ) -> PaymentsSuccessViewModel.Mode {
        
        .makePaymentFromDeposit(
            from: 1, to: 1,
            transferResponseDataDummy(documentStatus: documentStatus)
        )
    }
    
    func makePaymentToDeposit(
        documentStatus: TransferResponseData.DocumentStatus?
    ) -> PaymentsSuccessViewModel.Mode {
        
        .makePaymentToDeposit(
            from: 1, to: 1,
            transferResponseDataDummy(documentStatus: documentStatus)
        )
    }
    
    func meToMeMode(
        documentStatus: TransferResponseData.DocumentStatus?
    ) -> PaymentsSuccessViewModel.Mode {
        
        .meToMe(
            templateId: 1, from: 1, to: 1,
            transferResponseDataDummy(documentStatus: documentStatus))
    }
    
    func transferResponseDataDummy(
        documentStatus: TransferResponseData.DocumentStatus?
    ) -> TransferResponseData {
        .init(
            amount: 100,
            creditAmount: nil,
            currencyAmount: nil,
            currencyPayee: nil,
            currencyPayer: nil,
            currencyRate: nil,
            debitAmount: nil,
            fee: nil,
            needMake: nil,
            needOTP: nil,
            payeeName: nil,
            documentStatus: documentStatus,
            paymentOperationDetailId: 1,
            scenario: .ok
        )
    }
}
