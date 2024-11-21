//
//  XCTestCase+make.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.11.2024.
//

import XCTest

extension XCTestCase {
    
    /// Creates an instance of a given type `T` that inherits from `NSObject`.
    ///
    /// This factory method is particularly useful when working with types
    /// that are bridged from C and have a private `init()`. In such
    /// cases, you cannot directly initialize the type due to access control
    /// restrictions. This method leverages the Objective-C runtime to
    /// instantiate the object, bypassing the private initializer.
    ///
    /// - Parameters:
    ///   - file: The file name to use in the error message if the unwrap fails.
    ///   - line: The line number to use in the error message if the unwrap fails.
    /// - Throws: An error if the instance could not be created.
    /// - Returns: An instance of type `T`.
    func make<T: NSObject>(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        
        try XCTUnwrap((T.self as NSObject.Type).init() as? T, file: file, line: line)
    }
}
