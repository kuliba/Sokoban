//
//  Image+extTests.swift
//  
//
//  Created by Igor Malyarov on 14.12.2023.
//

import ForaTools
import SwiftUI
import XCTest

#if os(iOS)
final class Image_extTests: XCTestCase {
    
    func test_init_shouldFailForInvalidSVGString() {
        
        let invalidSVGString = UUID().uuidString
        
        let image = Image(svg: invalidSVGString)
        
        XCTAssertNil(image)
    }
    
    // TODO: add tests
}
#endif
