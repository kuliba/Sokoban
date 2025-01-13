//
//  ComponentStateTests.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest

final class ComponentStateTests: XCTestCase {
   
    //MARK: - test init

    func test_init_withMonthlySubscriptionType_shouldSetToMonthly() {
        
        let state: ComponentState = .monthlyOne
        
        XCTAssertEqual(state.subscriptionType, .monthly)
        XCTAssertEqual(state.subscriptionType.id, .monthly)
        XCTAssertEqual(state.selectionOption, .oneWithHtml)
        XCTAssertEqual(state.image, OptionWithMapImage.oneWithHtml.mapImage)
    }
    
    func test_init_withYearlySubscriptionType_shouldSetToYearly() {
        
        let state: ComponentState = .yearlyOne
        
        XCTAssertEqual(state.subscriptionType, .yearly)
        XCTAssertEqual(state.subscriptionType.id, .yearly)
        XCTAssertEqual(state.selectionOption, .oneWithHtml)
        XCTAssertEqual(state.image, OptionWithMapImage.oneWithHtml.mapImage)
    }
}
