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
