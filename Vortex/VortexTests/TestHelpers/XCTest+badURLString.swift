//
//  XCTest+badURLString.swift
//  VortexTests
//
//  Created by Igor Malyarov on 28.02.2025.
//

import XCTest

extension XCTestCase {
    
    var badURLString: String {
        
        if #available(iOS 17.0, *) {
            return "http://example.com:abc"
        } else {
            return " "
        }
    }
}
