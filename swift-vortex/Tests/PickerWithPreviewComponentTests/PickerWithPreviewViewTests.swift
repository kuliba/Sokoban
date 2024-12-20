//
//  PickerWithPreviewViewTests.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest
import SwiftUI

final class PickerWithPreviewViewTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let pickerWithPreviewView: PickerWithPreviewView = .init(
            state: .monthlyOne,
            send: { _ in },
            paymentAction: { },
            continueAction: { },
            checkUncheckImage: .default,
            viewConfig: .defaulf)
        
        XCTAssertEqual(pickerWithPreviewView.state, .monthlyOne)
        XCTAssertNotNil(pickerWithPreviewView.send)
        XCTAssertNotNil(pickerWithPreviewView.paymentAction)
        XCTAssertNotNil(pickerWithPreviewView.continueAction)
        XCTAssertEqual(pickerWithPreviewView.checkUncheckImage, .default)
        XCTAssertEqual(pickerWithPreviewView.viewConfig, .defaulf)
        XCTAssertNotNil(pickerWithPreviewView.body)
    }
}
