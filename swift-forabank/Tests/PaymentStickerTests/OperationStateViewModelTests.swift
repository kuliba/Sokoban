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
    
        
        return .init(state: .operation(.init(parameters: [])), blackBoxGet: { _,_ in })
    }
}
