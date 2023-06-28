//
//  TemplateButtonViewComponentTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 07.06.2023.
//

import XCTest
@testable import ForaBank

final class TemplateButtonViewComponentTests: XCTestCase {
   
    let model = Model.mockWithEmptyExcept()
}

extension TemplateButtonViewComponentTests {

    typealias ViewModel = TemplateButtonView.ViewModel
    
    func test_init_shouldSet_idleState() throws {

        let sut = makeSUT(state: .idle)
        
        XCTAssertEqual(sut.state, .idle)
    }
    
    func test_init_shouldSet_refreshState() throws {

        let sut = TemplateButtonView.ViewModel(
            model: model,
            state: .refresh,
            operationDetail: .stub()
        )
        
        XCTAssertEqual(sut.state, .refresh)
    }
    
    func test_init_paymentTemplateId_shouldSet_refreshState() throws {

        let sut = TemplateButtonView.ViewModel(
            model: model,
            state: .refresh,
            operationDetail: .stub(paymentTemplateId: nil)
        )
        
        XCTAssertEqual(sut.state, .refresh)
    }
    
    func test_convenienceInit_shouldSet_idleState() throws {

        let sut = TemplateButtonView.ViewModel(
            model: model,
            state: .idle,
            operationDetail: .stub()
        )
        
        XCTAssertEqual(sut.state, .idle)
    }
    
    func test_convenienceInit_withTemplateId_shouldSet_completeState() throws {

        let sut = TemplateButtonView.ViewModel(
            model: model,
            operationDetail: .stub(paymentTemplateId: 1)
        )
        
        XCTAssertEqual(ViewModel.State.complete, sut.state)
    }
    
    func test_convenienceInit_templateIdNil_shouldSet_idleState() throws {

        let sut = TemplateButtonView.ViewModel(
            model: model,
            operationDetail: .stub(paymentTemplateId: nil)
        )
        
        XCTAssertEqual(sut.state, .idle)
    }
}

// MARK: Computed property tests

extension TemplateButtonViewComponentTests {
    
    // MARK: Title
    func test_computedPropertyTitle_idleState_shouldReturnTemplate() throws {

        let sut = makeSUT(state: .idle)
        
        XCTAssertEqual(sut.title, "Шаблон")
    }
    
    func test_computedPropertyTitle_loadingState_shouldReturnTemplate() throws {

        let sut = makeSUT(state: .loading)
        
        XCTAssertEqual(sut.title, "Шаблон")
    }
    
    func test_computedPropertyTitle_refreshState_shouldReturnRefreshTemplate() throws {

        let sut = makeSUT(state: .refresh)
        
        XCTAssertEqual(sut.title, "Обновить шаблон?")
    }
}

//MAKR: binding tests

extension TemplateButtonViewComponentTests {
    
    func test_templateButton_setupStateOnTapActionButton_shouldReturn_idle() throws {

        let sut = OperationDetailViewModel(
            productStatement: .stub(),
            product: .stub(),
            model: model
        )
        
        let templateButton = TemplateButtonView.ViewModel(
            model: model,
            state: .idle,
            operationDetail: .stub()
        )
        
        sut?.templateButton = templateButton
        
        if let templateButton = sut?.templateButton {
            
            sut?.bindTemplateButton(with: templateButton)
            templateButton.action.send(TemplateButtonView.ViewModel.ButtonAction.tapAction)
            
            XCTWaiter().wait(for: [.init()], timeout: 1)

        }

        XCTAssertEqual(sut?.templateButton?.state, .idle)
    }
}

extension TemplateButtonViewComponentTests {
    
    typealias State = TemplateButtonView.ViewModel.State
    
    func makeSUT(state: State) -> TemplateButtonView.ViewModel {
        
        return TemplateButtonView.ViewModel(
            state: state,
            model: model,
            tapAction: {}
        )
    }
}

extension ProductStatementData {
    
    static func stub() -> ProductStatementData {
        
        return .init(
            mcc: nil,
            accountId: nil,
            accountNumber: "",
            amount: 20,
            cardTranNumber: nil,
            city: nil,
            comment: "",
            country: nil,
            currencyCodeNumeric: 1,
            date: Date(),
            deviceCode: nil,
            documentAmount: 20,
            documentId: 1,
            fastPayment: nil,
            groupName: "",
            isCancellation: nil,
            md5hash: "",
            merchantName: nil,
            merchantNameRus: nil,
            opCode: nil,
            operationId: "",
            operationType: .credit,
            paymentDetailType: .betweenTheir,
            svgImage: nil,
            terminalCode: nil,
            tranDate: nil,
            type: .inside
        )
    }
}

extension ProductData {
    
    static func stub() -> ProductData {
        
        return .init(
            id: 1,
            productType: .account,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "",
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "",
            openDate: nil,
            ownerId: 1,
            branchId: nil,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .init(
                description: ""
            ),
            largeDesign: .init(
                description: ""
            ),
            mediumDesign: .init(
                description: ""
            ),
            smallDesign: .init(
                description: ""
            ),
            fontDesignColor: .init(
                description: ""
            ),
            background: [
                .init(
                    description: ""
                )
            ],
            order: 10,
            isVisible: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: ""
        )
    }
}
