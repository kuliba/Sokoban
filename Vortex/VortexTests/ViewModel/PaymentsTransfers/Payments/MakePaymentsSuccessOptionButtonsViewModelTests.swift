//
//  MakePaymentsSuccessOptionButtonsViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 15.09.2023.
//

import XCTest
@testable import ForaBank

final class MakePaymentsSuccessOptionButtonsViewModelTests: XCTestCase {
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withRestrictedTransferEnum_shouldReturnNil() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            operationDetail: .stub(transferEnum: .accountClose)
        )
        
        XCTAssertNoDiff(button.map(\.id), [])
    }
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withOperationDetailNil() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels()
        
        XCTAssertNoDiff(button.map(\.id), [])
    }
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withTransferEnumMeToMe_shouldReturnButton() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            operationDetail: .stub(transferEnum: .meToMeDebit)
        )
        
        XCTAssertNoDiff(button.map(\.id), [.template])
    }
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withTransferEnumMeToMe_TempalteIdNil_shouldReturnButton() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            templateId: nil,
            operationDetail: .stub(transferEnum: .meToMeDebit)
        )
        
        XCTAssertNoDiff(button.map(\.id), [.template])
    }
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withMeToMePayment_shouldReturnButton() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            templateId: nil,
            meToMePayment: meToMePayment(),
            operationDetail: .stub(transferEnum: .meToMeDebit)
        )
        
        XCTAssertNoDiff(button.map(\.id), [.template])
    }
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withTemplateIdNilOperationDetailNil_shouldReturnNil() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            templateId: nil,
            operationDetail: nil
        )
        
        XCTAssertNoDiff(button.map(\.id), [])
    }
    
    
    func test_makePaymentsSuccessOptionButtonsButtonViewModels_templateButton_withTemplateId_shouldReturnNil() {
        
        let button = makeSUT().makePaymentsSuccessOptionButtonsModels(
            templateId: 2,
            operationDetail: .stub(
                transferEnum: .meToMeDebit
            )
        )
        
        XCTAssertNoDiff(button.map(\.id), [])
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        file: StaticString = #file, line: UInt = #line
    ) -> Model {
        
        let sut = Model.mockWithEmptyExcept()
        
        sut.paymentTemplates.value = [PaymentTemplateData.templateStub(
            paymentTemplateId: 1,
            type: .betweenTheir,
            parameterList: []
        )]
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func meToMePayment() -> MeToMePayment {
        
        .init(
            templateId: 1,
            payerProductId: 1,
            payeeProductId: 1,
            amount: 100
        )
    }
}

// MARK: - DSL

private extension Model {
    
    func makePaymentsSuccessOptionButtonsModels(
        templateId: Int? = 1,
        meToMePayment: MeToMePayment? = nil,
        operationDetail: OperationDetailData? = nil
    ) -> [any PaymentsSuccessOptionButtonsButtonViewModel] {
        
        let parameter = Payments.ParameterSuccessOptionButtons(
            options: [.template],
            operationDetail: operationDetail,
            templateID: templateId,
            meToMePayment: meToMePayment,
            operation: nil
        )
        
        return makePaymentsSuccessOptionButtonsButtonViewModels(
            withSource: parameter
        )
    }
}
