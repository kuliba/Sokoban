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
        
    func test_operationResult_shouldReturnNil() {
        
        let (sut, _) = makeSUT(state: .result)
        
        XCTAssertNoDiff(sut.operation?.parameters, nil)
    }
    
    func test_operationStateResult_shouldReturnEmptyScrollParameter() {
    
        let (sut, _) = makeSUT(
            state: .result
        )
        
        XCTAssertNoDiff(sut.scrollParameters, [])
    }
    
    func test_operationParametersEmpty_shouldReturnEmptyScrollParameter() {
    
        let (sut, _) = makeSUT(
            state: .operation
        )
        
        XCTAssertNoDiff(sut.scrollParameters, [])
    }
    
    func test_operationParameters_shouldReturnStickerAndProduct() {
    
        let (sut, _) = makeSUT(
            state: .operation,
            parameters: [
                .sticker(makeBannerStub()),
                .productSelector(makeProductStub())
            ]
        )
        
        XCTAssertNoDiff(sut.scrollParameters.count, 2)
    }
    
    func test_operationWithOutAmountParameter_shouldReturnNil() {
    
        let (sut, _) = makeSUT(
            state: .operation
        )
        
        XCTAssertNoDiff(sut.amountParameter, nil)
    }
    
    func test_operationAmountParameter_shouldReturnAmount() {
    
        let (sut, _) = makeSUT(
            state: .operation,
            parameters: [.amount(.init(value: "Value"))]
        )
        
        XCTAssertNoDiff(sut.amountParameter?.id, .amount)
    }
    
    func test_operationWithOutProduct_shouldReturnNil() {
        
        let (sut, _) = makeSUT(state: .operation)
        
        XCTAssertNoDiff(sut.product, nil)
    }
    
    func test_operationWithProduct_shouldReturnProduct() {
        
        let (sut, _) = makeSUT(
            state: .operation,
            parameters: [.productSelector(makeProductStub())]
        )
        
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
    
    func test_operationWithOutBanner_shouldReturnNil() {
        
        let (sut, _) = makeSUT(state: .operation)
        
        XCTAssertNoDiff(sut.banner, nil)
    }
    
    func test_operationWithBanner_shouldReturnBanner() {
        
        let (sut, _) = makeSUT(
            state: .operation,
            parameters: [.sticker(makeBannerStub())]
        )
        
        XCTAssertNoDiff(sut.banner, .init(
            title: "Title",
            description: "Description",
            image: .named("image"),
            options: []
        ))
    }
    
    func test_operationWithOutTransferType_shouldReturnNil() {
        
        let (sut, _) = makeSUT(state: .operation)
        
        XCTAssertNoDiff(sut.transferType, nil)
    }
    
    func test_operationWithTransferType_shouldReturnTransferType() {
        
        let (sut, _) = makeSUT(
            state: .operation,
            parameters: [.select(makeTransferTypeStub())]
        )
        
        XCTAssertNoDiff(sut.transferType, .init(
            id: .transferTypeSticker,
            value: "Value",
            title: "Title",
            placeholder: "PlaceHolder",
            options: [],
            state: .idle(.init(
                iconName: "iconName",
                title: "Title"
            ))
        ))
    }
    
    //MARK: Helpers
    
    typealias Parameter = PaymentSticker.Operation.Parameter
    private typealias Request = BlackBoxAPI.Request
    private typealias Completion = BlackBoxAPI.Completion
    
    private func makeSUT(
        state: OperationStateViewModel.OperationStateTests,
        parameters: [Parameter] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (OperationStateViewModel, Spy) {
        
        let spy = Spy()
        let sut = OperationStateViewModel(
            state: makeOperationState(state: state, parameters: parameters),
            blackBoxGet: spy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)

        return (sut, spy)
    }
    
    private final class Spy {
        
        private(set) var messages = [(request: Request, completion: Completion)]()

        var callCount: Int { messages.count }
        var requests: [Request] { messages.map(\.request) }
        
        func process(
            _ request: Request,
            _ completion: @escaping Completion
        ) {
         
            messages.append((request, completion))
        }
        
        func complete(
            with result: BlackBoxAPI.Result,
            at index: Int = 0
        ) {
            
            messages[index].completion(result)
        }
    }
    
    func anyEvent() -> Event {
        
        Event.continueButtonTapped(.continue)
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
