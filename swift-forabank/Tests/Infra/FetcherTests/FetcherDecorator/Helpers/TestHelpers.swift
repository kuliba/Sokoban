//
//  TestHelpers.swift
//  
//
//  Created by Igor Malyarov on 09.11.2023.
//

import Foundation

func anyRequest(
    value: String = UUID().uuidString
) -> Request {
    
    .init(value: value)
}

struct Request: Equatable {
    
    let value: String
}

func anyItem(
    value: String = UUID().uuidString
) -> Item {
    
    .init(value: value)
}

struct Item: Equatable {
    
    let value: String
}

func testError(
    _ message: String = UUID().uuidString
) -> TestError {
    
    TestError(message: message)
}

struct TestError: Error & Equatable {
    
    let message: String
}
