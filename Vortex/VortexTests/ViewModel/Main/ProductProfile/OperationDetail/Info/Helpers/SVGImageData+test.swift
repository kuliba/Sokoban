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
    
    static let testDocument: Self = {
        let description = """
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M13.8808 2H5.99969C5.46934 2 4.96071 2.21074 4.58569 2.58586C4.21068 2.96098 4 3.46975 4 4.00025V20.0023C4 20.5327 4.21068 21.0415 4.58569 21.4166C4.96071 21.7918 5.46934 22.0025 5.99969 22.0025H17.9978C18.5282 22.0025 19.0368 21.7918 19.4118 21.4166C19.7868 21.0415 19.9975 20.5327 19.9975 20.0023V8.11841M13.8808 2L19.9975 8.11841M13.8808 2V8.11841H19.9975" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.94043 15.5313H11.4775M6.94043 17.2962H11.4775M8.64184 13.7664L8.07471 19.0611M10.3433 13.7664L9.77612 19.0611" stroke="#999999" stroke-linecap="round" stroke-linejoin="round"/>
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
