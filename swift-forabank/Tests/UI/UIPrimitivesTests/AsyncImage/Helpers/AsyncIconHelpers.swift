//
//  AsyncIconHelpers.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import ForaTools
import SwiftUI
import UIPrimitives
import XCTest

extension Image {
    
    static let eraser: Self = .init(systemName: "eraser")
    static let pencil: Self = .init(systemName: "pencil")
    static let photo: Self = .init(systemName: "photo")
    static let placeholder: Self = .init(systemName: "rectangle.and.pencil.and.ellipsis")
    static let star: Self = .init(systemName: "star")
}

extension String {
    
    static let invalidSVG = "<svg>"
    
    static let smallSVG = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg>
"""
}

// MARK: - Helpers Tests

final class HelpersTest:XCTestCase {
    
    func test_invalidSVG_shouldDeliverImage() {
        
        XCTAssertNil(Image(svg: .invalidSVG))
    }
    
    func test_smallSVG_shouldDeliverImage() throws {
        
        try XCTAssertNotNil(XCTUnwrap(Image(svg: .smallSVG)))
    }
}
