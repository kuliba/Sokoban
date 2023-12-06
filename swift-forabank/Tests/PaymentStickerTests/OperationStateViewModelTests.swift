//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 06.12.2023.
//

import Foundation
import PaymentSticker
import XCTest

final class OperationStateViewModelTests {
    
    func inits() {
        
        fatalError()
    }
    
    //MARK: Helpers
    
    func makeSUT() -> OperationStateViewModel {
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
}
