//
//  XCTAssertNoDiff.swift
//  
//
//  Created by Дмитрий Савушкин on 06.12.2023.
//

import Foundation
import CustomDump
import XCTest

extension XCTestCase {
    
    func XCTAssertNoDiff<T>(
        _ expression1: @autoclosure () throws -> T,
        _ expression2: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T: Equatable {
        
        do {
            let expression1 = try expression1()
            let expression2 = try expression2()
            let message = message()
            
            XCTAssertNoDifference(
                expression1,
                expression2,
                message,
                file: file,
                line: line
            )
        } catch {
            XCTFail(
                """
                Assert failed with error "\(error)"
                """,
                file: file,
                line: line
            )
        }
    }
}
