//
//  SVGImageData+test.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.07.2023.
//

@testable import ForaBank

extension SVGImageData {
    
    /// - Warning: this does not work on simulator
    /// https://github.com/SVGKit/SVGKit/issues/762
    static let test: Self = {
        let description = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M17.3929 22H14.6071M11.3571 6C10.3315 6 9.5 6.89543 9.5 8V24C9.5 25.1046 10.3315 26 11.3571 26H20.6429C21.6685 26 22.5 25.1046 22.5 24V8C22.5 6.89543 21.6685 6 20.6429 6H16H11.3571Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
        let data = description.data(using: .utf8)!
        
        return .init(data: data)!
    }()
}

import XCTest

final class SVGImageDataTest: XCTestCase {

    func test_SVGImageDataTest() throws {
        
        #if targetEnvironment(simulator)
        // SVGImageData cannot be tested on simulator until SVGKit fixes the issue with new devices https://github.com/SVGKit/SVGKit/issues/762
        // XCTAssertNil(SVGImageData.test.image)
        #else
        XCTAssertNotNil(SVGImageData.test.image)
        #endif
    }
}
