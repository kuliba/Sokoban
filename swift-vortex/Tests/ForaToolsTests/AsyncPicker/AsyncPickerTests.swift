//
//  AsyncPickerEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 23.07.2024.
//

import ForaTools
import XCTest

class AsyncPickerTests: XCTestCase {

    // MARK: - Helpers
    
    struct Payload: Equatable {
        
        let value: String
    }
    
    struct Item: Equatable {
        
        let value: String
    }
    
    struct Response: Equatable {
        
        let value: String
    }
    
    func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
    
    func makeResponse(
        _ value: String = anyMessage()
    ) -> Response {
        
        return .init(value: value)
    }
    
    func makeItems(
        count: Int
    ) -> [Item] {
        
        let items = (0..<count).map { _ in
            
            makeItem()
        }
        
        precondition(items.count == count)
        return items
    }
}
