//
//  XCTestCase.swift
//
//
//  Created by Дмитрий Савушкин on 13.06.2024.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            
            XCTAssertNil(
                instance,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
}
