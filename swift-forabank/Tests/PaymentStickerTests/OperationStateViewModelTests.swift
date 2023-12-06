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
        
        return .init(state: .operation(.init(parameters: [])), blackBoxGet: { _,_ in })
    }
}
