//
//  SceneDelegateTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.11.2024.
//

@testable import ForaBank
import XCTest

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_shouldSetWindowAsKeyAndVisible() {
        
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    // MARK: - Helpers
    
    private class UIWindowSpy: UIWindow {
        
        var makeKeyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            
            makeKeyAndVisibleCallCount = 1
        }
    }
}
