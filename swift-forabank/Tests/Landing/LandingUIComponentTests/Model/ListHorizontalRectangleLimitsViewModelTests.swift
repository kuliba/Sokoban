//
//  ListHorizontalRectangleLimitsViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 10.06.2024.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class ListHorizontalRectangleLimitsViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(items: .default)
        
        XCTAssertEqual(sut.list, .default)
    }
    
    // MARK: - Helpers
    
    typealias Item = UILanding.List.HorizontalRectangleLimits.Item
    
    private func makeSUT(
        items: [Item]
    ) -> UILanding.List.HorizontalRectangleLimits {
        
        return .init(
            list: items
        )
    }
}

private extension Array where Element == UILanding.List.HorizontalRectangleLimits.Item.Limit {
    
    static let `default`: Self = [.init(id: "id", title: "limitTitle", colorHEX: "color")]
}

private extension Array where Element == UILanding.List.HorizontalRectangleLimits.Item {
    
    static let `default`: Self = [.init(action: .init(type: "action"), limitType: "limitType", md5hash: "md5Hash", title: "title", limits: .default)]
}
