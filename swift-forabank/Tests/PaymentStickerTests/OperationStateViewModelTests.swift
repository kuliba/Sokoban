//
//  OperationStateViewModelTests.swift
//  
//
//  Created by Дмитрий Савушкин on 06.12.2023.
//

import Foundation
import PaymentSticker
import XCTest

final class OperationStateViewModelTests: XCTestCase {
    
    func test_operationResult_shouldReturnNil() {
        
        let sut = makeSUT(state: .result)
        
        XCTAssertNoDiff(sut.operation?.parameters, nil)
    }
    
    func test_operationWithParameter_shouldReturnUpdateParameters() {
        
        let sut = makeSUT(state: .operation)
        XCTAssertNoDiff(sut.operation?.parameters, [])
        
        sut.updateOperation(with: [
            .productSelector(makeProductStub()),
            .sticker(makeBannerStub())
        ])
        
        XCTAssertNoDiff(sut.operation?.parameters.count, 2)
    }
    
    func test_operationStateResult_shouldReturnEmptyScrollParameter() {
    
        let sut = makeSUT(
            state: .result
        )
        
        XCTAssertNoDiff(sut.scrollParameters, [])
    }
    
    func test_operationParametersEmpty_shouldReturnEmptyScrollParameter() {
    
        let sut = makeSUT(
            state: .operation
        )
        
        XCTAssertNoDiff(sut.scrollParameters, [])
    }
    
    func test_operationWithOutProduct_shouldReturnNil() {
        
        let sut = makeSUT()
        
        XCTAssertNoDiff(sut.product, nil)
    }
    
    func test_operationWithProduct_shouldReturnProduct() {
        
        let sut = makeSUT(parameters: [.productSelector(makeProductStub())])
        
        XCTAssertNoDiff(sut.product, .init(
            state: .select,
            selectedProduct: .init(
                id: 1,
                title: "title",
                nameProduct: "nameProduct",
                balance: "100.0",
                balanceFormatted: "100 R",
                description: "description",
                cardImage: .named("cardImage"),
                paymentSystem: .named("paymentSystem"),
                backgroundImage: .named("backgroundImage"),
                backgroundColor: "color"
            ),
            allProducts: []
        ))
    }
    
    //MARK: Helpers
    
    typealias Parameter = PaymentSticker.Operation.Parameter
    
    func makeSUT(
        parameters: [Parameter] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> OperationStateViewModel {
        
        let sut = OperationStateViewModel(
            state: .operation(.init(parameters: parameters)),
            blackBoxGet: { _,_ in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
    
    private func makeOperationState(
        state: OperationStateViewModel.OperationStateTests,
        parameters: [Parameter] = []
    ) -> OperationStateViewModel.State {
        
        switch state {
        case .operation:
            return .operation(.init(parameters: parameters))
        case .result:
            return .result(.init(
                result: .success,
                title: "Title",
                description: "Description",
                amount: "Amount",
                paymentID: .init(id: 1)
            ))
        }
    }
    
    func makeProductStub() -> Parameter.ProductSelector {
        
        return .init(
            state: .select,
            selectedProduct: .init(
                id: 1,
                title: "title",
                nameProduct: "nameProduct",
                balance: "100.0",
                balanceFormatted: "100 R",
                description: "description",
                cardImage: .named("cardImage"),
                paymentSystem: .named("paymentSystem"),
                backgroundImage: .named("backgroundImage"),
                backgroundColor: "color"),
            allProducts: []
        )
    }
    
    func makeBannerStub() -> Parameter.Sticker {
        
        return .init(
            title: "Title",
            description: "Description",
            image: .named("image"),
            options: []
        )
    }
    
    func makeTransferTypeStub() -> Parameter.Select {
        
        return .init(
            id: .transferTypeSticker,
            value: "Value",
            title: "Title",
            placeholder: "PlaceHolder",
            options: [],
            state: .idle(.init(
                iconName: "iconName",
                title: "Title"
            ))
        )
    }
}

private extension OperationStateViewModel {
    
    var operationStateTest: OperationStateTests {
        
        switch state {
        case .operation:
            return .operation
        case .result:
            return .result
        }
    }
    
    enum OperationStateTests: Equatable {
        
        case operation
        case result
    }
}
