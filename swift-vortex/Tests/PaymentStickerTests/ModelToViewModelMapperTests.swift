//
//  ModelToViewModelMapperTests.swift
//  
//
//  Created by Дмитрий Савушкин on 27.11.2023.
//

import Foundation
import PaymentSticker
import XCTest

final class ModelToViewModelMapperTests: XCTestCase {
    
    func test_modelMapperParameter_shouldReturnSelectParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .select)
        
        XCTAssertEqual(parameterViewModel.type, .select)
    }
    
    func test_modelMapperParameter_shouldReturnAmountParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .amount)
        
        XCTAssertEqual(parameterViewModel.type, .amount)
    }
    
    func test_modelMapperParameter_shouldReturnInputParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .input)
        
        XCTAssertEqual(parameterViewModel.type, .input)
    }
    
    func test_modelMapperParameter_shouldReturnProductParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .product)
        
        XCTAssertEqual(parameterViewModel.type, .product)
    }
    
    func test_modelMapperParameter_shouldReturnStickerParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .sticker)
        
        XCTAssertEqual(parameterViewModel.type, .sticker)
    }
    
    func test_modelMapperParameter_shouldReturnTipParameterViewModel() {
        
        let sut = makeSUT()
        let parameterViewModel = sut.mapWrapper(parameterType: .tip)
        
        XCTAssertEqual(parameterViewModel.type, .tip)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ModelToViewModelMapper {
        
        let spy = Spy()
        let sut = ModelToViewModelMapper(action: spy.event(event:))
        
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return sut
    }
    
    private final class Spy {
        
        private (set) var events = [Event]()
        
        func event(event: Event) {
            
            events.append(event)
        }
    }
}

private extension ModelToViewModelMapper {
    
    func mapWrapper(
        parameterType: ParameterViewModel.ParameterType
    ) -> ParameterViewModel {
        
        let operation: PaymentSticker.Operation = .init(parameters: [])
        return self.map(operation, parameterStub(parameterType))
    }
    
    private func parameterStub(
        _ parameterType: ParameterViewModel.ParameterType
    ) -> PaymentSticker.Operation.Parameter {
        
        switch parameterType {
        case .amount:
            return .amount(.init(value: ""))
        case .input:
            return .input(.init(value: "", title: .code, warning: nil))
        case .product:
            return .productSelector(.init(
                state: .select,
                selectedProduct: .init(
                    id: 1,
                    title: "title",
                    nameProduct: "nameProduct",
                    balance: 1,
                    balanceFormatted: "balanceFormatted",
                    description: "description",
                    cardImage: .named(""),
                    paymentSystem: .named(""),
                    backgroundImage: nil,
                    backgroundColor: "", 
                    clover: .named("")
                ),
                allProducts: [])
            )
            
        case .select:
            return .select(.init(
                id: .selector,
                value: nil,
                title: "title",
                placeholder: "placeholder",
                options: [],
                staticOptions: [],
                state: .idle(.init(
                    iconName: "",
                    title: "Title"
                ))
            ))
            
        case .sticker:
            return .sticker(.init(
                title: "title",
                description: "description",
                image: .named("name"),
                options: []
            ))
        case .tip:
            return .tip(.init(title: "title"))
        }
    }
}

private extension ParameterViewModel {
    
    var type: ParameterType {
        switch self {
        case .amount:
            return .amount
        case .input:
            return .input
        case .product:
            return .product
        case .select:
            return .select
        case .sticker:
            return .sticker
        case .tip:
            return .tip
        }
    }
    
    enum ParameterType {
        
        case sticker
        case tip
        case select
        case product
        case amount
        case input
    }
}
